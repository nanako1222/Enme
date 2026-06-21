#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
yarn install
bundle exec rails webpacker:compile
bundle exec rails assets:precompile
bundle exec rails db:migrate

# レストランデータが空のときだけseedを実行（DB再作成時のみ自動seed）
if bundle exec rails runner "exit(Restaurant.count > 0 ? 0 : 1)" 2>/dev/null; then
  echo "データあり。シードをスキップします。"
else
  echo "DBが空です。シードを実行します..."
  bundle exec rails db:seed
fi
