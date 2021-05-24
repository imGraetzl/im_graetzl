source 'https://rubygems.org'

ruby '2.7.2'

gem 'rails', '~> 6.1.0'
gem 'puma'
gem 'puma_worker_killer'
gem 'pg'
gem 'activerecord-postgis-adapter'
gem 'rgeo'
gem 'rgeo-geojson'
gem 'delayed_job_active_record'

gem 'rack-attack'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-rewrite'

gem 'aasm'
gem 'acts-as-taggable-on'
gem 'browser'
gem 'cocoon'
gem 'devise'
gem 'friendly_id'
gem 'httparty'
gem 'jbuilder'
gem 'kaminari'
gem 'remotipart'
gem 'sitemap_generator'
gem 'prawn'
gem 'prawn-table'

gem 'gibbon', '~> 3.0', '>= 3.0.2'
gem 'newrelic_rpm'
gem 'rollbar'
gem 'scout_apm'

gem "shrine", "~> 3.0"
gem "aws-sdk-s3", "~> 1"
gem "image_processing", "~> 1.8"

gem 'mini_racer'

gem 'sass-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'underscore-rails'
gem 'autoprefixer-rails'

gem 'activeadmin'
gem 'rabl'
gem 'oj'
gem 'jquery-ui-rails', '6.0.0'
gem 'bb-ruby'
gem 'stripe'

group :development do
  # gem 'spring'
  gem 'letter_opener'
end

group :development, :test do
  gem 'listen', '~> 3.0.5'
  # Helpers don't work if required, https://github.com/rspec/rspec-rails/issues/1525
  gem 'rails-controller-testing', require: false
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'dotenv-rails'
  gem 'guard-livereload'
  gem 'foreman', require: false
  gem 'faker'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
