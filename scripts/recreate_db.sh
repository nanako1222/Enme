#!/usr/bin/env bash
set -euo pipefail

# ===============================================================
#  Render PostgreSQL 再作成スクリプト（Enme / Case B デモDB）
#
#  安全設計（実装済み）
#    R2 : 非対話実行の fail-open 封鎖（明示フラグが必須）
#    R1 : 削除対象を Enme DB 1件のみに限定（Exactly-one rule）
#    Case B guard : Render 側の policy marker 完全一致を要求
#    R4 : buildCommand を一切変更しない
#    R5 : cleanup / 中断時の状態報告 / 推測復元をしない
#    R6 : secret をディスクへ書かない
#    R7 : env-vars 全体PUT を不変条件で検証（DATABASE_URL の value 1箇所のみ変更）
#    実行ログ / 成功・失敗通知 / deploy 判別 / health check / automatic mode
#
#  未実施
#    launchd 再有効化 / end-to-end 自動再作成テスト
# ===============================================================

# ---------------------------------------------------------------
# 引数解析（R2 対策 / fail-closed）
#   許可: 引数なし / --yes / --dry-run / --yes --dry-run / --automatic
#   --automatic と --dry-run は排他。--automatic と --yes も併用不可（冗長）。
#   不明・重複・引数過多はすべて非0終了（黙って無視しない）。
#   .env 読み込みより前に判定するため、引数誤りでは .env を読まない。
# ---------------------------------------------------------------
usage() {
  echo "使用法: $(basename "$0") [--yes] [--dry-run] | --automatic" >&2
  echo "  引数なし       … 対話端末からの手動実行（確認文字列の入力を要求）" >&2
  echo "  --yes          … 手動の非対話実行を明示的に許可する" >&2
  echo "  --dry-run      … 破壊的操作を行わず、実行計画のみ表示する" >&2
  echo "  --automatic    … 自動運用モード（非対話可 / ログ必須 / 通知必須 / dry-run と排他）" >&2
  echo "  ※ 同一フラグの重複、--automatic と --dry-run/--yes の併用は不可。" >&2
}

ASSUME_YES=false
DRY_RUN=false
AUTOMATIC=false
seen_yes=0
seen_dry=0
seen_auto=0

if (( $# > 2 )); then
  echo "エラー: 引数が多すぎます: $*" >&2
  usage
  exit 2
fi

while (( $# > 0 )); do
  case "$1" in
    --yes)       seen_yes=$((seen_yes + 1));  ASSUME_YES=true; shift ;;
    --dry-run)   seen_dry=$((seen_dry + 1));  DRY_RUN=true;    shift ;;
    --automatic) seen_auto=$((seen_auto + 1)); AUTOMATIC=true;  shift ;;
    *)
      echo "エラー: 不明な引数です: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if (( seen_yes > 1 )) || (( seen_dry > 1 )) || (( seen_auto > 1 )); then
  echo "エラー: 同じ引数が重複しています" >&2
  usage
  exit 2
fi
if $AUTOMATIC && $DRY_RUN; then
  echo "エラー: --automatic と --dry-run は同時に指定できません（排他）" >&2
  usage
  exit 2
fi
if $AUTOMATIC && $ASSUME_YES; then
  echo "エラー: --automatic は非対話実行を含むため --yes と併用できません" >&2
  usage
  exit 2
fi

if $DRY_RUN; then
  RUN_MODE="dry-run"
elif $AUTOMATIC; then
  RUN_MODE="automatic"
else
  RUN_MODE="manual"
fi

CONFIRM_PHRASE="DELETE ENME DB"

# ---------------------------------------------------------------
# 定数（いずれも secret ではない）
# ---------------------------------------------------------------
ENME_NAME_PREFIX="enme-db-"
ENME_DATABASE_NAME="enme_prod"
ENME_DATABASE_USER="enme_user"
LIST_LIMIT=20
POLICY_MARKER_KEY="ENME_DB_RESET_POLICY"
POLICY_MARKER_VALUE="DEMO_RESET_ALLOWED"
REQUIRED_BUILD_MARKER="bin/render-build.sh"

# deploy 監視（無限待機はしない）
#   Production Recovery 2026-09-12 実測：deploy に約35分を要した。
#   従来の 600 秒（10分）では正常な deploy でも timeout（exit 43）となったため、
#   実測値に対し約15分のバッファを持つ 3000 秒（50分）へ変更する。
DEPLOY_POLL_SEC=10
DEPLOY_MAX_ATTEMPTS=300

# health check 対象（DB非依存 / DB依存の両方を確認する）
SITE_URL="${ENME_SITE_URL:-https://enme.onrender.com}"
HEALTH_PATH="/health"
HEALTH_BODY_MARKER="ok"
DB_PAGE_PATH="/"
DB_PAGE_MARKER="top-card__name"
HEALTH_MAX_ATTEMPTS=10
HEALTH_BACKOFF_SEC=6

# 実行ログ（リポジトリ外。Git へ誤コミットされない場所）
LOG_DIR="${ENME_LOG_DIR:-${HOME}/Library/Logs/Enme}"
LOG_FILE="${LOG_DIR}/recreate_db_runs.log"
LOG_MAX_BYTES=1048576
RUN_ID="${ENME_RUN_ID:-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
STARTED_AT="$(date '+%Y-%m-%d %H:%M:%S')"

# ---------------------------------------------------------------
# 進捗フラグ
# ---------------------------------------------------------------
GUARD_RESULT="not-reached"
CAND_COUNT="unknown"
DID_DELETE="no"
DID_CREATE="no"
DID_ENV_SWITCH="no"
DEPLOY_RESULT="not-reached"
HEALTH_RESULT="not-reached"
NOTIFY_FAILED=0
LOG_AVAILABLE=0
CLEANUP_FAILED=0

# ---------------------------------------------------------------
# ログ（secret は一切書かない）
# ---------------------------------------------------------------
rotate_log() {
  [ -f "${LOG_FILE}" ] || return 0
  local size
  size=$(wc -c < "${LOG_FILE}" 2>/dev/null || echo 0)
  if [ "${size}" -gt "${LOG_MAX_BYTES}" ]; then
    mv -f "${LOG_FILE}" "${LOG_FILE}.1" 2>/dev/null || return 1
  fi
  return 0
}

init_log() {
  if mkdir -p "${LOG_DIR}" 2>/dev/null; then
    rotate_log || true
    if : >> "${LOG_FILE}" 2>/dev/null; then
      chmod 600 "${LOG_FILE}" 2>/dev/null || true
      LOG_AVAILABLE=1
      return 0
    fi
  fi
  LOG_AVAILABLE=0
  return 1
}

log_line() {
  [ "${LOG_AVAILABLE}" = "1" ] || return 0
  printf '%s\n' "$1" >> "${LOG_FILE}" 2>/dev/null || true
}

# ---------------------------------------------------------------
# 通知（個人情報をコードへ書かない / 通知失敗を成功に変えない）
#   カレンダー記録は ENME_NOTIFY_CALENDAR が設定されている場合のみ。
# ---------------------------------------------------------------
notify_result() {
  local kind="$1" code="$2" title msg
  if [ "${kind}" = "SUCCESS" ]; then
    title="Enme DB自動再作成 SUCCESS"
    msg="成功 / ${STARTED_AT} / run ${RUN_ID}"
  else
    title="Enme DB自動再作成 FAILED"
    msg="失敗 exit=${code} / run ${RUN_ID} / ログ: ${LOG_FILE}"
  fi

  if ! osascript -e "display notification \"${msg}\" with title \"${title}\"" >/dev/null 2>&1; then
    NOTIFY_FAILED=1
    echo "警告: 通知の送信に失敗しました（処理結果の判定には影響しません）" >&2
  fi

  if [ -n "${ENME_NOTIFY_CALENDAR:-}" ]; then
    if ! osascript >/dev/null 2>&1 <<CALEOF
tell application "Calendar"
    tell calendar "${ENME_NOTIFY_CALENDAR}"
        make new event with properties {summary:"${title} (${RUN_ID})", start date:(current date), end date:((current date) + 1 * hours)}
    end tell
end tell
CALEOF
    then
      NOTIFY_FAILED=1
      echo "警告: カレンダー記録に失敗しました（処理結果の判定には影響しません）" >&2
    fi
  fi
}

# ---------------------------------------------------------------
# 終了処理（R5 対策）
# ---------------------------------------------------------------
on_exit() {
  local rc=$?
  trap - EXIT

  local result="FAILURE"
  if (( rc == 0 )); then result="SUCCESS"; fi


  if (( rc != 0 )); then
    {
      echo ""
      echo "--------- 中断時の状態 ---------"
      echo "  run ID              : ${RUN_ID}"
      echo "  mode                : ${RUN_MODE}"
      echo "  Case B guard        : ${GUARD_RESULT}"
      echo "  DB 候補数           : ${CAND_COUNT}"
      echo "  DELETE 実行         : ${DID_DELETE}"
      echo "  CREATE 実行         : ${DID_CREATE}"
      echo "  DATABASE_URL 切替   : ${DID_ENV_SWITCH}"
      echo "  deploy              : ${DEPLOY_RESULT}"
      echo "  health check        : ${HEALTH_RESULT}"
      echo "  buildCommand 変更   : none"
      echo "  一時ファイル         : none"
      if [ "${LOG_AVAILABLE}" = "1" ]; then
        echo "  ログ                : ${LOG_FILE}"
      else
        echo "  ログ                : 書き込めませんでした"
      fi
      if [ "${DID_ENV_SWITCH}" = "yes" ] && [ "${DEPLOY_RESULT}" != "live" ]; then
        echo ""
        echo "  注意: DATABASE_URL は新DBへ切替済みですが、deploy 完了を確認できていません。"
        echo "        旧DBは削除済みのため DATABASE_URL の巻き戻しは行いません（推測復元をしない方針）。"
      fi
      echo "--------------------------------"
    } >&2
  fi

  if [ "${RUN_MODE}" = "automatic" ]; then
    notify_result "${result}" "${rc}"
  fi

  log_line "---- run ${RUN_ID} ----"
  log_line "run_id=${RUN_ID}"
  log_line "mode=${RUN_MODE}"
  log_line "started_at=${STARTED_AT}"
  log_line "ended_at=$(date '+%Y-%m-%d %H:%M:%S')"
  log_line "case_b_guard=${GUARD_RESULT}"
  log_line "candidate_count=${CAND_COUNT}"
  log_line "did_delete=${DID_DELETE}"
  log_line "did_create=${DID_CREATE}"
  log_line "env_switch=${DID_ENV_SWITCH}"
  log_line "deploy=${DEPLOY_RESULT}"
  log_line "health_check=${HEALTH_RESULT}"
  log_line "build_command_change=none"
  log_line "temp_files=none"
  log_line "notify_failed=${NOTIFY_FAILED}"
  log_line "result=${result}"
  log_line "exit_code=${rc}"
  log_line "summary run=${RUN_ID} mode=${RUN_MODE} result=${result} exit=${rc} guard=${GUARD_RESULT} cand=${CAND_COUNT} delete=${DID_DELETE} create=${DID_CREATE} env=${DID_ENV_SWITCH} deploy=${DEPLOY_RESULT} health=${HEALTH_RESULT}"

  if (( CLEANUP_FAILED != 0 )); then
    echo "エラー: cleanup に失敗したため、結果を成功として扱いません。" >&2
    exit 21
  fi
  exit "${rc}"
}
trap on_exit EXIT

# automatic mode ではログが必須
if [ "${RUN_MODE}" = "automatic" ]; then
  if ! init_log; then
    echo "エラー: automatic mode ではログが必須ですが、ログを初期化できませんでした: ${LOG_DIR}" >&2
    exit 60
  fi
else
  init_log || echo "警告: ログを初期化できませんでした（処理は続行します）: ${LOG_DIR}" >&2
fi

# ---------------------------------------------------------------
# .env を読み込む（secret は変数に保持するだけで、ログ・ファイルへ出さない）
# ---------------------------------------------------------------
umask 077
set -a
source "$(dirname "$0")/../.env"
set +a

API="https://api.render.com/v1"
H=(-H "Authorization: Bearer $RENDER_API_KEY" -H "Accept: application/json" -H "Content-Type: application/json")
SERVICE_ID="srv-d6j6il7kijhs739ce130"

echo "========================================"
echo "  Render PostgreSQL 再作成スクリプト"
echo "  run ID : ${RUN_ID}"
echo "  mode   : ${RUN_MODE}"
echo "========================================"
echo ""
if [ "${RUN_MODE}" != "dry-run" ]; then
  echo "⚠️  実行すると以下が行われます："
  echo "   ・既存のEnme PostgreSQLを削除（存在する場合のみ）"
  echo "   ・新しいPostgreSQLを作成"
  echo "   ・DATABASE_URL を新DBへ切替（他の環境変数は変更しない）"
  echo "   ・自動デプロイ（seed は bin/render-build.sh 側で実施）"
  echo "   ・health check（/health と DB依存ページ）"
  echo ""
fi

# ---------------------------------------------------------------
# 実行ゲート（R2 対策 / fail-closed）
# ---------------------------------------------------------------
if ! $ASSUME_YES && ! $AUTOMATIC; then
  if [ ! -t 0 ]; then
    echo "エラー: 非対話環境のため実行を中止しました。" >&2
    echo "  この処理は Render 本番の PostgreSQL を削除して作り直す破壊的操作です。" >&2
    echo "  非対話環境で実行するには --yes（手動）または --automatic（自動運用）の" >&2
    echo "  明示が必要です（dry-run の場合も同様）。" >&2
    echo "  手動実行する場合は、対話可能なターミナルから引数なしで実行してください。" >&2
    exit 3
  fi

  if ! $DRY_RUN; then
    echo "続行するには「${CONFIRM_PHRASE}」と入力してEnter（それ以外は中止）:"
    read -r confirm
    if [ "${confirm}" != "${CONFIRM_PHRASE}" ]; then
      echo "確認文字列が一致しませんでした。キャンセルしました。"
      exit 0
    fi
  fi
fi

echo ""

# =============================================================
# 1. サービス情報と buildCommand の確認（R4 対策）
# =============================================================
echo "[1/9] サービス情報を取得中..."
if ! service_info=$(curl -sf "$API/services/$SERVICE_ID" "${H[@]}"); then
  echo "エラー: サービス情報の取得に失敗しました。中止します。" >&2
  exit 10
fi

set +e
svc_out=$(printf '%s' "$service_info" | python3 -c '
import sys, json
marker = sys.argv[1]
try:
    d = json.loads(sys.stdin.read())
except Exception:
    sys.stderr.write("STOP: service info JSON parse failed\n")
    sys.exit(11)
if not isinstance(d, dict):
    sys.stderr.write("STOP: service info is not an object\n")
    sys.exit(12)
owner = d.get("ownerId")
if not isinstance(owner, str) or owner.strip() == "":
    sys.stderr.write("STOP: ownerId not found\n")
    sys.exit(13)
found = []
def walk(o):
    if isinstance(o, dict):
        for k, v in o.items():
            if k == "buildCommand":
                found.append(v)
            walk(v)
    elif isinstance(o, list):
        for v in o:
            walk(v)
walk(d)
vals = []
for v in found:
    if isinstance(v, str) and v.strip() != "" and v not in vals:
        vals.append(v)
if len(vals) == 0:
    sys.stderr.write("STOP: current buildCommand not found (no guessed restore)\n")
    sys.exit(22)
if len(vals) > 1:
    sys.stderr.write("STOP: multiple buildCommand values found; cannot determine current value\n")
    sys.exit(22)
if marker not in vals[0]:
    sys.stderr.write("STOP: current buildCommand does not reference %s (value not logged)\n" % marker)
    sys.exit(23)
sys.stdout.write("OWNER_ID=%s\n" % owner)
' "$REQUIRED_BUILD_MARKER")
svc_rc=$?
set -e
if (( svc_rc != 0 )); then
  echo "エラー: サービス情報の検証に失敗しました（exit ${svc_rc}）。中止します。" >&2
  exit "$svc_rc"
fi
owner_id=$(printf '%s\n' "$svc_out" | sed -n 's/^OWNER_ID=//p')
if [ -z "${owner_id}" ]; then
  echo "エラー: ownerId を取得できませんでした。中止します。" >&2
  exit 13
fi
echo "      完了 (ownerID: ${owner_id})"
echo "      buildCommand は ${REQUIRED_BUILD_MARKER} を参照しています（変更しません）"

# =============================================================
# 2. Case B destructive-operation guard
# =============================================================
echo "[2/9] Case B policy marker を確認中..."
if ! env_json=$(curl -sf "$API/services/$SERVICE_ID/env-vars" "${H[@]}"); then
  echo "エラー: 環境変数一覧の取得に失敗しました。中止します。" >&2
  exit 24
fi

set +e
printf '%s' "$env_json" | python3 -c '
import sys, json
key_want, val_want = sys.argv[1], sys.argv[2]
try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.stderr.write("GUARD-STOP: env-vars JSON parse failed\n")
    sys.exit(30)
if not isinstance(data, list):
    sys.stderr.write("GUARD-STOP: env-vars is not an array\n")
    sys.exit(30)
found = None
for item in data:
    if not isinstance(item, dict):
        continue
    inner = item.get("envVar")
    ev = inner if isinstance(inner, dict) else item
    if not isinstance(ev, dict):
        continue
    if ev.get("key") == key_want:
        found = ev.get("value")
        break
if found is None:
    sys.stderr.write("GUARD-STOP: policy marker %s is not set\n" % key_want)
    sys.exit(31)
if not isinstance(found, str) or found.strip() == "":
    sys.stderr.write("GUARD-STOP: policy marker %s is empty\n" % key_want)
    sys.exit(32)
if found != val_want:
    sys.stderr.write("GUARD-STOP: policy marker %s does not exactly match (value not logged)\n" % key_want)
    sys.exit(33)
sys.stderr.write("GUARD-PASS: %s matched exactly\n" % key_want)
' "$POLICY_MARKER_KEY" "$POLICY_MARKER_VALUE"
guard_rc=$?
set -e
if (( guard_rc != 0 )); then
  GUARD_RESULT="FAIL(${guard_rc})"
  echo "エラー: Case B guard を通過できませんでした（exit ${guard_rc}）。" >&2
  echo "  DELETE / CREATE / env 切替 / deploy へは進みません。" >&2
  exit "$guard_rc"
fi
GUARD_RESULT="PASS"
echo "      Case B guard: PASS"

# =============================================================
# 3. 既存 Enme DB の特定（R1 対策）
# =============================================================
echo "[3/9] 既存 Enme DB を特定中..."
if ! dbs=$(curl -sf "$API/postgres?ownerId=$owner_id&limit=$LIST_LIMIT" "${H[@]}"); then
  echo "エラー: PostgreSQL 一覧の取得に失敗しました。中止します。" >&2
  exit 10
fi

set +e
selection=$(printf '%s' "$dbs" | python3 -c '
import sys, json
owner, limit_s, prefix, want_dbname, want_dbuser = sys.argv[1:6]
limit = int(limit_s)
try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.stderr.write("R1-STOP: postgres list JSON parse failed\n")
    sys.exit(11)
if not isinstance(data, list):
    sys.stderr.write("R1-STOP: postgres list is not an array\n")
    sys.exit(12)
if len(data) >= limit:
    sys.stderr.write("R1-STOP: result reached limit %d; cannot guarantee no further pages\n" % limit)
    sys.exit(13)
cands = []
for i, item in enumerate(data):
    if not isinstance(item, dict):
        sys.stderr.write("R1-STOP: element %d is not an object\n" % i)
        sys.exit(14)
    inner = item.get("postgres")
    pg = inner if isinstance(inner, dict) else item
    if not isinstance(pg, dict):
        sys.stderr.write("R1-STOP: element %d postgres is not an object\n" % i)
        sys.exit(14)
    pid = pg.get("id")
    if not isinstance(pid, str) or pid.strip() == "":
        sys.stderr.write("R1-STOP: element %d id missing/empty\n" % i)
        sys.exit(15)
    name = pg.get("name")
    if not isinstance(name, str) or name.strip() == "":
        sys.stderr.write("R1-STOP: element %d name missing/empty/non-string; cannot evaluate Enme condition\n" % i)
        sys.exit(16)

    # Preflight（2026-09-12）で databaseName / databaseUser が一覧レスポンスに
    # 実在することを確認済み。よってこの2つは必須フィールドとして扱い、
    # 欠落・null・空・非文字列は「候補0件」ではなく STOP とする。
    dn = pg.get("databaseName")
    if not isinstance(dn, str) or dn.strip() == "":
        sys.stderr.write("R1-STOP: element %d databaseName missing/null/empty/non-string\n" % i)
        sys.exit(34)
    du = pg.get("databaseUser")
    if not isinstance(du, str) or du.strip() == "":
        sys.stderr.write("R1-STOP: element %d databaseUser missing/null/empty/non-string\n" % i)
        sys.exit(35)

    # Enme 候補条件（実環境で取得できるフィールドのみ使用）
    #   name        : "enme-db-" で始まる
    #   databaseName: "enme_prod" で始まる（Render がサフィックスを付与するため前方一致）
    #   databaseUser: "enme_user" と完全一致
    ok = name.startswith(prefix) and dn.startswith(want_dbname) and du == want_dbuser

    # ownerId は一覧レスポンスに存在しないことを実環境で確認済み。
    # 必須条件にはしないが、万一存在して不一致なら候補から除外する（安全側）。
    o = pg.get("ownerId")
    if o is not None and o != owner:
        ok = False

    if ok:
        cands.append((pid, name, dn, du, o is not None))
if len(cands) > 1:
    sys.stderr.write("R1-STOP: %d Enme DB candidates found; refusing to delete unless exactly one\n" % len(cands))
    for c in cands:
        sys.stderr.write("  candidate: %s (%s)\n" % (c[1], c[0]))
    sys.exit(18)
if len(cands) == 0:
    sys.stderr.write("R1-INFO: 0 Enme DB candidates (fetch/parse/limit checks all passed)\n")
    sys.stdout.write("ENME_DB_COUNT=0\n")
    sys.exit(0)
sys.stderr.write("R1-INFO: matched name=%s databaseName=%s databaseUser=%s (ownerId in list response: %s)\n" % (
    cands[0][1], cands[0][2], cands[0][3], "present" if cands[0][4] else "absent"))
sys.stdout.write("ENME_DB_COUNT=1\n")
sys.stdout.write("ENME_DB_ID=%s\n" % cands[0][0])
sys.stdout.write("ENME_DB_NAME=%s\n" % cands[0][1])
' "$owner_id" "$LIST_LIMIT" "$ENME_NAME_PREFIX" "$ENME_DATABASE_NAME" "$ENME_DATABASE_USER")
sel_rc=$?
set -e
if (( sel_rc != 0 )); then
  echo "エラー: 削除対象を安全に特定できませんでした（exit ${sel_rc}）。" >&2
  echo "  DELETE / CREATE / env 切替 / deploy へは進みません。" >&2
  exit "$sel_rc"
fi

cand_count=$(printf '%s\n' "$selection" | sed -n 's/^ENME_DB_COUNT=//p')
target_id=$(printf '%s\n' "$selection" | sed -n 's/^ENME_DB_ID=//p')
target_name=$(printf '%s\n' "$selection" | sed -n 's/^ENME_DB_NAME=//p')
if [ "${cand_count}" != "0" ] && [ "${cand_count}" != "1" ]; then
  echo "エラー: 候補数を確定できませんでした。中止します。" >&2
  exit 19
fi
if [ "${cand_count}" = "1" ] && { [ -z "${target_id}" ] || [ -z "${target_name}" ]; }; then
  echo "エラー: 対象の ID / name を取得できませんでした。中止します。" >&2
  exit 19
fi
CAND_COUNT="${cand_count}"
echo "      Enme DB 候補数: ${cand_count}"

# =============================================================
# 4. 実行計画の表示（dry-run はここで終了）
# =============================================================
echo "[4/9] 実行計画:"
echo "      -------------------------------"
echo "      run ID                : ${RUN_ID}"
echo "      mode                  : ${RUN_MODE}"
echo "      Case B guard          : PASS"
echo "      Enme DB 候補数        : ${cand_count}"
if [ "${cand_count}" = "1" ]; then
  echo "      対象 name             : ${target_name}"
  echo "      対象 id               : ${target_id}"
  echo "      DELETE 予定           : あり（上記1件のみ）"
else
  echo "      対象                  : なし（既存DBが0件）"
  echo "      DELETE 予定           : なし（create-only）"
fi
echo "      CREATE 予定           : あり（databaseName=${ENME_DATABASE_NAME}）"
echo "      DATABASE_URL 切替予定 : あり（他の環境変数は変更しない）"
echo "      deploy 予定           : あり（seed は ${REQUIRED_BUILD_MARKER} 側で実施）"
echo "      buildCommand 変更予定 : なし"
echo "      health check 予定     : ${HEALTH_PATH} と ${DB_PAGE_PATH}（DB依存）"
echo "      -------------------------------"

if $DRY_RUN; then
  echo ""
  echo "dry-run のため、破壊的操作は行わず終了します。"
  echo "  実行した API 呼び出し: 参照のみ（サービス情報 / 環境変数一覧 / DB一覧）"
  echo "  DELETE: 0 回 / CREATE: 0 回 / env 更新: 0 回 / deploy: 0 回 / health check: 未実施"
  DEPLOY_RESULT="skipped(dry-run)"
  HEALTH_RESULT="skipped(dry-run)"
  exit 0
fi

# =============================================================
# 5. 既存 Enme DB の削除（0件ならスキップ）
# =============================================================
if [ "${cand_count}" = "1" ]; then
  echo "[5/9] 既存 Enme DB を削除中..."
  echo "        name : ${target_name}"
  echo "        id   : ${target_id}"
  if ! curl -sf -X DELETE "$API/postgres/$target_id" "${H[@]}" > /dev/null; then
    echo "エラー: 対象DBの削除に失敗しました（${target_name} / ${target_id}）。" >&2
    echo "  以降の DB 作成・deploy へは進みません。" >&2
    exit 20
  fi
  DID_DELETE="yes"
  echo "      削除しました。10秒待機..."
  sleep 10
else
  echo "[5/9] 既存 Enme DB は 0 件のため削除をスキップします（create-only）"
fi

# =============================================================
# 6. 新しい DB を作成
# =============================================================
echo "[6/9] 新しいDBを作成中..."
db_label="enme-db-$(date +%m%d%H%M)"
if ! new_db=$(curl -sf -X POST "$API/postgres" "${H[@]}" \
  -d "{\"name\":\"$db_label\",\"databaseName\":\"$ENME_DATABASE_NAME\",\"databaseUser\":\"$ENME_DATABASE_USER\",\"plan\":\"free\",\"region\":\"singapore\",\"version\":\"16\",\"ownerId\":\"$owner_id\"}"); then
  echo "エラー: 新しいDBの作成に失敗しました。中止します。" >&2
  exit 25
fi
DID_CREATE="yes"

set +e
new_db_id=$(printf '%s' "$new_db" | python3 -c '
import sys, json
try:
    d = json.loads(sys.stdin.read())
except Exception:
    sys.stderr.write("STOP: create response JSON parse failed\n")
    sys.exit(25)
if not isinstance(d, dict):
    sys.exit(25)
inner = d.get("postgres")
pg = inner if isinstance(inner, dict) else d
pid = pg.get("id") if isinstance(pg, dict) else None
if not isinstance(pid, str) or pid.strip() == "":
    sys.stderr.write("STOP: created DB id not found\n")
    sys.exit(25)
sys.stdout.write(pid)
')
create_rc=$?
set -e
if (( create_rc != 0 )) || [ -z "${new_db_id}" ]; then
  echo "エラー: 作成した DB の id を取得できませんでした。中止します。" >&2
  exit 25
fi
echo "      name: ${db_label}"
echo "      id  : ${new_db_id}"

# =============================================================
# 7. DB の準備待機 + 接続情報の取得（接続文字列はログに出さない）
# =============================================================
echo "[7/9] DBの準備を待機中（最大5分）..."
for i in $(seq 1 60); do
  sleep 5
  db_info=$(curl -sf "$API/postgres/$new_db_id" "${H[@]}" || echo "")
  status=$(printf '%s' "$db_info" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status') or d.get('postgres',{}).get('status','unknown'))" 2>/dev/null || echo "unknown")
  echo "      ステータス: ${status} ($((i*5))秒経過)"
  if [ "${status}" = "available" ]; then
    break
  fi
  if (( i == 60 )); then
    echo "エラー: DBが available になりませんでした（タイムアウト）。" >&2
    exit 26
  fi
done

if ! conn_info=$(curl -sf "$API/postgres/$new_db_id/connection-info" "${H[@]}"); then
  echo "エラー: 接続情報の取得に失敗しました。中止します。" >&2
  exit 27
fi

set +e
internal_url=$(printf '%s' "$conn_info" | python3 -c '
import sys, json
try:
    d = json.loads(sys.stdin.read())
except Exception:
    sys.exit(27)
u = d.get("internalConnectionString") if isinstance(d, dict) else None
if not isinstance(u, str) or u.strip() == "":
    sys.stderr.write("STOP: internalConnectionString not found\n")
    sys.exit(27)
sys.stdout.write(u)
')
conn_rc=$?
set -e
if (( conn_rc != 0 )) || [ -z "${internal_url}" ]; then
  echo "エラー: 接続URLを取得できませんでした。中止します。" >&2
  exit 27
fi
echo "      接続情報を取得しました（値はログに出力しません）"

# =============================================================
# 8. DATABASE_URL を更新して deploy
#    R7: 全体PUT を不変条件で検証（DATABASE_URL の value 1箇所のみ変更）
#    R6: メモリ内処理のみ。接続文字列は argv ではなく環境変数で渡す。
#    R4: buildCommand は変更しない。
# =============================================================
echo "[8/9] DATABASE_URL を更新して deploy 中..."
if ! env_json_now=$(curl -sf "$API/services/$SERVICE_ID/env-vars" "${H[@]}"); then
  echo "エラー: 環境変数一覧の再取得に失敗しました。中止します。" >&2
  exit 24
fi

set +e
put_payload=$(printf '%s' "$env_json_now" | ENME_NEW_DB_URL="$internal_url" python3 -c '
import sys, json, os

# R7: DATABASE_URL の value 1箇所だけを変更し、それ以外は完全一致することを機械検証する。
new_url = os.environ.get("ENME_NEW_DB_URL", "")
if new_url.strip() == "":
    sys.stderr.write("R7-STOP: new DATABASE_URL is empty\n")
    sys.exit(28)

try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.stderr.write("R7-STOP: env-vars JSON parse failed\n")
    sys.exit(28)
if not isinstance(data, list):
    sys.stderr.write("R7-STOP: env-vars is not an array\n")
    sys.exit(28)
if len(data) == 0:
    sys.stderr.write("R7-STOP: env-vars list is empty\n")
    sys.exit(28)

before = []
for idx, item in enumerate(data):
    if not isinstance(item, dict):
        sys.stderr.write("R7-STOP: entry %d is not an object\n" % idx)
        sys.exit(28)
    inner = item.get("envVar")
    ev = inner if isinstance(inner, dict) else item
    if not isinstance(ev, dict):
        sys.stderr.write("R7-STOP: entry %d envVar is not an object\n" % idx)
        sys.exit(28)
    k = ev.get("key")
    if not isinstance(k, str) or k == "":
        sys.stderr.write("R7-STOP: entry %d key missing/empty/non-string\n" % idx)
        sys.exit(28)
    if "value" not in ev:
        sys.stderr.write("R7-STOP: entry %s value field missing\n" % k)
        sys.exit(28)
    v = ev.get("value")
    if v is None or not isinstance(v, str):
        sys.stderr.write("R7-STOP: entry %s value is null or non-string\n" % k)
        sys.exit(28)
    before.append((k, v))

keys = [k for k, _ in before]
if len(keys) != len(set(keys)):
    dups = sorted(set([k for k in keys if keys.count(k) > 1]))
    sys.stderr.write("R7-STOP: duplicate keys detected: %s\n" % ",".join(dups))
    sys.exit(28)

if "DATABASE_URL" not in keys:
    sys.stderr.write("R7-STOP: DATABASE_URL not present in current env-vars\n")
    sys.exit(28)

after = [(k, new_url if k == "DATABASE_URL" else v) for k, v in before]

# --- 不変条件の機械検証 ---
if len(after) != len(before):
    sys.stderr.write("R7-STOP: entry count changed\n")
    sys.exit(28)
if [k for k, _ in after] != [k for k, _ in before]:
    sys.stderr.write("R7-STOP: key list changed\n")
    sys.exit(28)
if set(k for k, _ in after) != set(k for k, _ in before):
    sys.stderr.write("R7-STOP: key set changed\n")
    sys.exit(28)
diff = [k for (k, vb), (_, va) in zip(before, after) if vb != va]
for k, vb in before:
    if k == "DATABASE_URL":
        continue
    va = dict(after)[k]
    if vb != va:
        sys.stderr.write("R7-STOP: value changed for non-DATABASE_URL key %s\n" % k)
        sys.exit(28)
if len(diff) > 1:
    sys.stderr.write("R7-STOP: more than one value changed (%d)\n" % len(diff))
    sys.exit(28)
if len(diff) == 1 and diff[0] != "DATABASE_URL":
    sys.stderr.write("R7-STOP: the changed key is not DATABASE_URL\n")
    sys.exit(28)

sys.stderr.write("R7-PASS: entries=%d changed=%d changed_key=%s\n" % (
    len(after), len(diff), diff[0] if diff else "none"))
sys.stdout.write(json.dumps([{"key": k, "value": v} for k, v in after]))
')
payload_rc=$?
set -e
if (( payload_rc != 0 )) || [ -z "${put_payload}" ]; then
  echo "エラー: 環境変数の更新内容が不変条件を満たしませんでした。PUT を実行せず中止します。" >&2
  exit 28
fi

if ! printf '%s' "$put_payload" | curl -sf -X PUT "$API/services/$SERVICE_ID/env-vars" "${H[@]}" --data @- > /dev/null; then
  echo "エラー: DATABASE_URL の更新に失敗しました。中止します。" >&2
  exit 29
fi
unset put_payload
DID_ENV_SWITCH="yes"
echo "      DATABASE_URL を更新しました（変更は1箇所のみ）"

if ! deploy_resp=$(curl -sf -X POST "$API/services/$SERVICE_ID/deploys" "${H[@]}" -d '{"clearCache":"do_not_clear"}'); then
  DEPLOY_RESULT="trigger-failed"
  echo "エラー: deploy の起動に失敗しました。" >&2
  exit 40
fi
DEPLOY_RESULT="triggered"

set +e
deploy_id=$(printf '%s' "$deploy_resp" | python3 -c '
import sys, json
try:
    d = json.loads(sys.stdin.read())
except Exception:
    sys.exit(40)
i = d.get("id") if isinstance(d, dict) else None
if not isinstance(i, str) or i.strip() == "":
    sys.stderr.write("STOP: deploy id not found\n")
    sys.exit(40)
sys.stdout.write(i)
')
dep_rc=$?
set -e
if (( dep_rc != 0 )) || [ -z "${deploy_id}" ]; then
  echo "エラー: deploy ID を取得できませんでした。" >&2
  exit 40
fi
echo "      deploy ID: ${deploy_id}"

echo "      deploy 完了を待機中（最大 $((DEPLOY_MAX_ATTEMPTS * DEPLOY_POLL_SEC / 60)) 分・無限待機なし）..."
deploy_final="timeout"
for i in $(seq 1 "${DEPLOY_MAX_ATTEMPTS}"); do
  sleep "${DEPLOY_POLL_SEC}"
  deploy_status=$(curl -sf "$API/services/$SERVICE_ID/deploys/$deploy_id" "${H[@]}" 2>/dev/null | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status') or 'unknown')" 2>/dev/null || echo "unknown")
  echo "      ステータス: ${deploy_status} ($((i * DEPLOY_POLL_SEC))秒経過)"
  case "${deploy_status}" in
    live)
      deploy_final="live"; break ;;
    build_failed|update_failed|pre_deploy_failed)
      deploy_final="failed"; break ;;
    canceled|cancelled)
      deploy_final="canceled"; break ;;
  esac
done

DEPLOY_RESULT="${deploy_final}"
case "${deploy_final}" in
  live)
    echo "      deploy 成功（live）" ;;
  failed)
    echo "エラー: deploy が失敗しました（status=${deploy_status}）。Render のログを確認してください。" >&2
    echo "  health check は実施しません（deploy 失敗を成功扱いしない）。" >&2
    exit 41 ;;
  canceled)
    echo "エラー: deploy がキャンセルされました（status=${deploy_status}）。" >&2
    echo "  health check は実施しません。" >&2
    exit 42 ;;
  *)
    echo "エラー: deploy 完了を確認できませんでした（タイムアウト）。" >&2
    echo "  health check は実施しません。" >&2
    exit 43 ;;
esac

# =============================================================
# 9. health check
#    deploy 完了だけで SUCCESS にしない。
#    /health（DB非依存）と DB依存ページの両方が OK で初めて SUCCESS。
#    DB依存ページは HTTP 200 だけでは不十分（DB到達可でも未seedなら200のため）、
#    DB行が描画されたことを示すマーカーの有無まで確認する。
# =============================================================
echo "[9/9] health check（${HEALTH_PATH} と ${DB_PAGE_PATH}）..."

fetch_status_and_body() {
  # $1=url  → 出力1行目=HTTPステータス / 2行目以降=本文
  local url="$1" resp
  resp=$(curl -s -L --max-time 30 -w '\n%{http_code}' "${url}" 2>/dev/null || printf '\n000')
  printf '%s\n' "$(printf '%s' "${resp}" | tail -1)"
  printf '%s' "${resp}" | sed '$d'
}

health_ok=0
dbpage_ok=0
dbpage_seeded=0
last_health_code="000"
last_db_code="000"

for attempt in $(seq 1 "${HEALTH_MAX_ATTEMPTS}"); do
  h_out=$(fetch_status_and_body "${SITE_URL}${HEALTH_PATH}")
  last_health_code=$(printf '%s\n' "${h_out}" | head -1)
  h_body=$(printf '%s\n' "${h_out}" | tail -n +2)
  health_ok=0
  if [ "${last_health_code}" = "200" ] && printf '%s' "${h_body}" | grep -q "${HEALTH_BODY_MARKER}"; then
    health_ok=1
  fi

  d_out=$(fetch_status_and_body "${SITE_URL}${DB_PAGE_PATH}")
  last_db_code=$(printf '%s\n' "${d_out}" | head -1)
  d_body=$(printf '%s\n' "${d_out}" | tail -n +2)
  dbpage_ok=0
  dbpage_seeded=0
  if [ "${last_db_code}" = "200" ]; then
    dbpage_ok=1
    if printf '%s' "${d_body}" | grep -q "${DB_PAGE_MARKER}"; then
      dbpage_seeded=1
    fi
  fi

  echo "      試行 ${attempt}/${HEALTH_MAX_ATTEMPTS}: health=${last_health_code} dbpage=${last_db_code} db_rows=${dbpage_seeded}"

  if [ "${health_ok}" = "1" ] && [ "${dbpage_ok}" = "1" ] && [ "${dbpage_seeded}" = "1" ]; then
    break
  fi
  if [ "${attempt}" -lt "${HEALTH_MAX_ATTEMPTS}" ]; then
    sleep $(( HEALTH_BACKOFF_SEC * attempt ))
  fi
done

if [ "${health_ok}" != "1" ]; then
  HEALTH_RESULT="health-endpoint-failed(${last_health_code})"
  echo "エラー: health endpoint が正常応答しませんでした（${HEALTH_PATH} / status=${last_health_code}）。" >&2
  exit 50
fi
if [ "${dbpage_ok}" != "1" ]; then
  HEALTH_RESULT="db-page-failed(${last_db_code})"
  echo "エラー: DB依存ページが正常応答しませんでした（${DB_PAGE_PATH} / status=${last_db_code}）。" >&2
  echo "  DB への到達性が確認できないため SUCCESS としません。" >&2
  exit 51
fi
if [ "${dbpage_seeded}" != "1" ]; then
  HEALTH_RESULT="db-page-empty"
  echo "エラー: DB依存ページは応答しましたが、DB行が描画されていません（seed 未反映の可能性）。" >&2
  exit 52
fi

HEALTH_RESULT="OK"
echo "      health check: OK（health endpoint / DB依存ページ / DB行描画）"

echo ""
echo "========================================"
echo "  完了（SUCCESS）"
echo "  run ID : ${RUN_ID}"
echo "  サイト : ${SITE_URL}"
echo "========================================"
