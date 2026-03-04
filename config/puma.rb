# config/puma.rb

# スレッド数の設定
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# ポート番号と環境の設定
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }

# プロセスIDの保存場所
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# 自動再起動の設定
plugin :tmp_restart
