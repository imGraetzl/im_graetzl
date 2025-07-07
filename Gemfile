source 'https://rubygems.org'

ruby '3.3.7'

gem 'rails', '~> 7.1.3'
gem 'puma'
gem 'puma_worker_killer', '~> 1.0'
gem 'pg'
gem 'activerecord-postgis-adapter', '~> 9.0'
gem 'rgeo'
gem 'rgeo-geojson'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'activerecord-import'
gem 'active_link_to'

gem 'rack-attack'
gem 'rack-cors', '~> 2.0', require: 'rack/cors'
gem 'rack-rewrite'

gem 'aasm'
gem 'acts-as-taggable-on'
gem 'browser'
gem 'cocoon'
gem 'devise'
gem 'devise-guests'
gem 'devise_masquerade'
gem 'friendly_id'
gem 'http'
gem 'jbuilder'
gem 'kaminari'
gem 'remotipart'
gem 'sitemap_generator'
gem 'prawn'
gem 'prawn-table'

gem 'platform-api'
gem 'gibbon', '~> 3.0', '>= 3.0.2'
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-delayed_job"
gem "skylight"

gem "shrine", "~> 3.6"
gem "aws-sdk-s3", "~> 1"
gem "image_processing", "~> 1.14"
gem 'marcel'

gem "terser"
gem 'sassc-rails'
gem 'jquery-rails'
gem 'underscore-rails'
gem 'autoprefixer-rails'

gem 'activeadmin', '~> 3.3.0'
gem 'rabl'
gem 'oj'
gem 'jquery-ui-rails'
gem 'bb-ruby'
gem 'stripe', '~> 15.2'

gem 'caxlsx'
gem 'caxlsx_rails'

group :development do
  gem 'letter_opener'
end

group :development, :test do
  gem 'listen'
  gem 'rails-controller-testing', require: false
  gem 'rspec-rails', '< 8.0'
  gem 'factory_bot_rails'
  gem 'dotenv-rails'
  gem 'foreman', require: false
  gem 'faker'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]