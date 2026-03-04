require "active_support/core_ext/integer/time"

Rails.application.configure do
  # 基本設定
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # 1. 静的ファイル（CSS/JS）をRails自身が配信できるように設定（Renderでの404/500対策）
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || true

  # 2. アセットのコンパイル設定
  config.assets.compile = true

  # ストレージとログレベル
  config.active_storage.service = :local
  config.log_level = :info
  config.log_tags = [ :request_id ]

  # メール設定
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  config.log_formatter = ::Logger::Formatter.new

  # 3. ★最重要★ RenderのLogs画面にログを出すための設定
  if ENV["RAILS_LOG_TO_STDOUT"].present? || ENV["RENDER"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
