#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
yarn install
bundle exec rails webpacker:compile
bundle exec rails assets:precompile
bundle exec rails db:migrate

# レストランデータが空のときだけseedを実行（DB再作成時のみ自動seed）
if bundle exec rails runner "exit(Restaurant.count > 50 ? 0 : 1)" 2>/dev/null; then
  echo "データあり。シードをスキップします。"
else
  echo "DBが空です。シードを実行します..."
  bundle exec rails db:seed
fi

# 画像が未添付のレストランがあれば添付する
ATTACHED=$(bundle exec rails runner "print ActiveStorage::Attachment.where(record_type: 'Restaurant', name: 'image').count" 2>/dev/null || echo "0")
TOTAL=$(bundle exec rails runner "print Restaurant.count" 2>/dev/null || echo "0")
echo "店舗画像: ${ATTACHED}件添付済 / ${TOTAL}件"
if [ "$TOTAL" -gt "0" ] && [ "$ATTACHED" -lt "$TOTAL" ]; then
  echo "未添付の画像があります。添付します（時間がかかります）..."
  bundle exec rails images:attach_missing
fi
