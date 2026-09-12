#!/usr/bin/env bash
# ===============================================================
#  launchd 用エントリポイント（Enme DB 自動再作成）
#
#  役割は薄い wrapper に限定する。
#    ・本体を automatic mode で起動する
#    ・本体が trap まで到達できなかった場合（強制終了など）に、
#      無言で終わらせないための最終防衛ラインとして通知する
#
#  通知・ログの本体は scripts/recreate_db.sh 側が行う。
#  個人情報（メールアドレス等）はコードへ書かない。
#    カレンダー記録が必要な場合のみ ENME_NOTIFY_CALENDAR を
#    .env 等の非コミット領域で設定する（未設定ならカレンダー記録はしない）。
#
#  注意: launchd は現在 bootout + disable 済み（Safety Hold 中）。
#        再有効化は残作業の完了後にのみ行う。
# ===============================================================
set -uo pipefail

# スクリプト自身の位置からプロジェクトルートを導出する（絶対パスを埋め込まない）
DIR="$(cd "$(dirname "$0")/.." && pwd)"
MAIN="${DIR}/scripts/recreate_db.sh"

LOG_DIR="${ENME_LOG_DIR:-${HOME}/Library/Logs/Enme}"
LOG_FILE="${LOG_DIR}/recreate_db_runs.log"
WRAPPER_LOG="${LOG_DIR}/recreate_db_wrapper.log"
WRAPPER_LOG_MAX_BYTES=1048576

ENME_RUN_ID="${ENME_RUN_ID:-auto-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
export ENME_RUN_ID

mkdir -p "${LOG_DIR}" 2>/dev/null || true
if [ -f "${WRAPPER_LOG}" ]; then
  wsize=$(wc -c < "${WRAPPER_LOG}" 2>/dev/null || echo 0)
  if [ "${wsize}" -gt "${WRAPPER_LOG_MAX_BYTES}" ]; then
    mv -f "${WRAPPER_LOG}" "${WRAPPER_LOG}.1" 2>/dev/null || true
  fi
fi
chmod 600 "${WRAPPER_LOG}" 2>/dev/null || true

wlog() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "${WRAPPER_LOG}" 2>/dev/null || true; }

notify_failure_fallback() {
  local code="$1"
  osascript -e "display notification \"失敗 exit=${code} / run ${ENME_RUN_ID} / ログ: ${LOG_FILE}\" with title \"Enme DB自動再作成 FAILED\"" >/dev/null 2>&1 \
    || wlog "WARN wrapper fallback notification failed run=${ENME_RUN_ID}"
  if [ -n "${ENME_NOTIFY_CALENDAR:-}" ]; then
    osascript >/dev/null 2>&1 <<CALEOF || wlog "WARN wrapper fallback calendar failed run=${ENME_RUN_ID}"
tell application "Calendar"
    tell calendar "${ENME_NOTIFY_CALENDAR}"
        make new event with properties {summary:"Enme DB自動再作成 FAILED (${ENME_RUN_ID})", start date:(current date), end date:((current date) + 1 * hours)}
    end tell
end tell
CALEOF
  fi
}

wlog "START run=${ENME_RUN_ID} main=${MAIN}"

if [ ! -x "${MAIN}" ]; then
  wlog "FATAL main script not found or not executable: ${MAIN} run=${ENME_RUN_ID}"
  notify_failure_fallback "127"
  exit 127
fi

"${MAIN}" --automatic
rc=$?

# 本体が trap まで到達していれば、実行ログに summary 行が残る。
# 残っていない場合は本体が通知に到達できていないため、ここで必ず通知する。
notified_by_main=0
if [ -f "${LOG_FILE}" ] && grep -q "summary run=${ENME_RUN_ID} " "${LOG_FILE}" 2>/dev/null; then
  notified_by_main=1
fi

if [ "${notified_by_main}" = "1" ]; then
  wlog "END run=${ENME_RUN_ID} exit=${rc} (main reported; notification handled by main)"
else
  wlog "END run=${ENME_RUN_ID} exit=${rc} (main did NOT reach its trap; wrapper notifying)"
  notify_failure_fallback "${rc}"
  if [ "${rc}" = "0" ]; then
    wlog "WARN run=${ENME_RUN_ID} main exited 0 but produced no summary; treating as failure"
    rc=61
  fi
fi

exit "${rc}"
