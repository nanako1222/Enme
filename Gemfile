source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Rails core
gem 'rails', '~> 6.1.6', '>= 6.1.6.1'

# データベースの設定
group :development, :test do
  # ローカル開発用
  gem 'sqlite3', '~> 1.4'
end

group :production do
  # Render本番用
  gem 'pg'
end

# App Server
gem 'puma', '~> 5.6'
gem 'nio4r', '~> 2.6'

# Assets & Frontend (ここが重要！)
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails'
gem 'bootstrap', '~> 5.1.3'  # 本番でのエラー解消のために追加
gem 'popper_js'              # Bootstrap 5の動作に必要
gem 'image_processing', '~> 1.2'

# Efficiency
gem 'bootsnap', '>= 1.4.4', require: false

# Authentication & Logic
gem 'devise'
gem 'kaminari', '~> 1.2.1'
gem 'enum_help'
gem 'ransack'
gem 'dotenv-rails'
gem 'faker'

# Mailer requirements for Ruby 3.1+ (Renderでのエラー防止)
gem "net-smtp"
gem "net-pop"
gem "net-imap"

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  gem 'webdrivers'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem "factory_bot_rails"
end

# Windows configuration
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
