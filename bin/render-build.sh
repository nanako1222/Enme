#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
yarn install
bundle exec rails webpacker:compile
bundle exec rails assets:precompile
bundle exec rails db:migrate
