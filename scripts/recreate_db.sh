#!/usr/bin/env bash
set -euo pipefail

# .envを読み込む
set -a
source "$(dirname "$0")/../.env"
set +a

API="https://api.render.com/v1"
H=(-H "Authorization: Bearer $RENDER_API_KEY" -H "Accept: application/json" -H "Content-Type: application/json")
SERVICE_ID="srv-d6j6il7kijhs739ce130"
BUILD_CMD_BASE="yarn install; bundle install; bundle exec rails webpacker:compile; bundle exec rails assets:precompile; bundle exec rails db:migrate"

echo "========================================"
echo "  Render PostgreSQL 再作成スクリプト"
echo "========================================"
echo ""
echo "⚠️  実行すると以下が行われます："
echo "   ・既存のPostgreSQLを削除"
echo "   ・新しいPostgreSQLを作成"
echo "   ・シードデータを投入"
echo "   ・自動デプロイ"
echo ""
echo "続けますか？「yes」と入力してEnter:"
read -r confirm
if [[ "$confirm" != "yes" ]]; then
  echo "キャンセルしました。"
  exit 0
fi

echo ""

# 1. オーナーIDを取得
echo "[1/8] サービス情報を取得中..."
service_info=$(curl -sf "$API/services/$SERVICE_ID" "${H[@]}")
owner_id=$(echo "$service_info" | python3 -c "import sys,json; print(json.load(sys.stdin)['ownerId'])")
echo "      完了 (ownerID: $owner_id)"

# 2. 既存のDBを削除
echo "[2/8] 既存のDBを確認・削除中..."
dbs=$(curl -sf "$API/postgres?ownerId=$owner_id&limit=20" "${H[@]}")
db_ids=$(echo "$dbs" | python3 -c "
import sys,json
items = json.load(sys.stdin)
for item in items:
    pg = item.get('postgres') or item
    if pg.get('id'):
        print(pg['id'])
" 2>/dev/null || echo "")

if [[ -n "$db_ids" ]]; then
  while IFS= read -r db_id; do
    [[ -z "$db_id" ]] && continue
    echo "      削除中: $db_id"
    curl -sf -X DELETE "$API/postgres/$db_id" "${H[@]}" > /dev/null || true
    sleep 3
  done <<< "$db_ids"
  echo "      削除完了。10秒待機..."
  sleep 10
else
  echo "      既存のDBなし。"
fi

# 3. 新しいDBを作成
echo "[3/8] 新しいDBを作成中..."
db_label="enme-db-$(date +%m%d)"
new_db=$(curl -sf -X POST "$API/postgres" "${H[@]}" \
  -d "{\"name\":\"$db_label\",\"databaseName\":\"enme_prod\",\"databaseUser\":\"enme_user\",\"plan\":\"free\",\"region\":\"singapore\",\"version\":\"16\",\"ownerId\":\"$owner_id\"}")
new_db_id=$(echo "$new_db" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id') or d.get('postgres',{}).get('id'))")
echo "      DB ID: $new_db_id"

# 4. DBが利用可能になるまで待機
echo "[4/8] DBの準備を待機中（最大5分）..."
for i in $(seq 1 60); do
  sleep 5
  db_info=$(curl -sf "$API/postgres/$new_db_id" "${H[@]}")
  status=$(echo "$db_info" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status') or d.get('postgres',{}).get('status','unknown'))" 2>/dev/null || echo "unknown")
  echo "      ステータス: $status ($((i*5))秒経過)"
  if [[ "$status" == "available" ]]; then
    break
  fi
  if [[ $i -eq 60 ]]; then
    echo "タイムアウト。Renderダッシュボードで確認してください。"
    exit 1
  fi
done

# 5. 内部接続URLを手動入力してもらう（Render APIは接続URLを返さない仕様）
echo "[5/8] RenderダッシュボードからInternal Database URLを取得してください"
echo "      https://dashboard.render.com → 新しいDB (enme-db-XXXX) → Internal Database URL"
echo ""
echo "Internal Database URLを貼り付けてEnter:"
read -r internal_url

if [[ -z "$internal_url" ]]; then
  echo "URLが入力されませんでした。中断します。"
  exit 1
fi
echo "      URL設定完了"

# 6. DATABASE_URLを更新
echo "[6/8] DATABASE_URLを更新中..."
curl -sf "$API/services/$SERVICE_ID/env-vars" "${H[@]}" > /tmp/render_env_vars.json
python3 - "$internal_url" /tmp/render_env_vars.json > /tmp/render_updated_vars.json << 'PYEOF'
import sys, json
new_url = sys.argv[1]
with open(sys.argv[2]) as f:
    data = json.load(f)
result = []
found = False
for item in data:
    v = item['envVar']
    if v['key'] == 'DATABASE_URL':
        result.append({'key': 'DATABASE_URL', 'value': new_url})
        found = True
    else:
        result.append({'key': v['key'], 'value': v['value']})
if not found:
    result.append({'key': 'DATABASE_URL', 'value': new_url})
print(json.dumps(result))
PYEOF
curl -sf -X PUT "$API/services/$SERVICE_ID/env-vars" "${H[@]}" -d @/tmp/render_updated_vars.json > /dev/null
echo "      更新完了"

# 7. ビルドコマンドにdb:seedを追加してデプロイ
echo "[7/8] db:seed付きでデプロイ中..."
build_with_seed="$BUILD_CMD_BASE; bundle exec rails db:seed"
curl -sf -X PATCH "$API/services/$SERVICE_ID" "${H[@]}" \
  -d "{\"buildCommand\":\"$build_with_seed\"}" > /dev/null

deploy_resp=$(curl -sf -X POST "$API/services/$SERVICE_ID/deploys" "${H[@]}" -d '{"clearCache":"do_not_clear"}')
deploy_id=$(echo "$deploy_resp" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "      デプロイID: $deploy_id"

echo "      デプロイ完了を待機中（最大10分）..."
for i in $(seq 1 60); do
  sleep 10
  deploy_status=$(curl -sf "$API/services/$SERVICE_ID/deploys/$deploy_id" "${H[@]}" | \
    python3 -c "import sys,json; print(json.load(sys.stdin)['status'])" 2>/dev/null || echo "unknown")
  echo "      ステータス: $deploy_status ($((i*10))秒経過)"
  if [[ "$deploy_status" == "live" ]]; then break; fi
  if [[ "$deploy_status" == "build_failed" ]]; then
    echo "デプロイ失敗。Renderのログを確認してください。"
    exit 1
  fi
  if [[ $i -eq 60 ]]; then
    echo "タイムアウト。Renderダッシュボードで確認してください。"
    exit 1
  fi
done

# 8. ビルドコマンドからdb:seedを削除
echo "[8/8] ビルドコマンドを元に戻し中..."
curl -sf -X PATCH "$API/services/$SERVICE_ID" "${H[@]}" \
  -d "{\"buildCommand\":\"$BUILD_CMD_BASE\"}" > /dev/null
echo "      完了"

echo ""
echo "========================================"
echo "  ✅ 完了！"
echo "  サイト: https://enme.onrender.com"
echo "========================================"
