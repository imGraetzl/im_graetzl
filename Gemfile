source 'https://rubygems.org'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7.1'
# Use puma as default webserver
gem 'puma'
# Use postgresql as the database for Active Record
gem 'pg'
# postgis adapter
gem 'activerecord-postgis-adapter', '~> 3.1'
# ruby lib for geospatial data
gem 'rgeo'
# rgeo geojson module for encode/decode
gem 'rgeo-geojson'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails'
# js helper utilities
gem 'underscore-rails'
# Parse CSS and add vendor prefixes to CSS rules using values from the Can I Use website
gem 'autoprefixer-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'mandrill-api', '~> 1.0.53', require: "mandrill"
group :doc do
  gem 'sdoc'
end

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
group :development do
  gem 'spring'
  # open mail in browser
  gem 'letter_opener'
  # debug kill N+1 queries and unused eager loading
  gem 'bullet'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'byebug'
end

group :development, :test, :staging do
  gem 'faker'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'test_after_commit'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# to query json apis
gem 'httparty'
# use devise for authentication
gem 'devise'
# refile
gem 'refile', require: ['refile/rails']
gem 'refile-mini_magick'
gem 'refile-s3'
gem 'aws-sdk'
# use seo-friendly urls
gem 'friendly_id'
# activeadmin for admin interface (pre version)
gem 'activeadmin', '~> 1.0.0.pre4'
# submit multipart forms with ajax
gem 'remotipart'
# pagination
gem 'kaminari'
# rack middleware for enforcing rewrite rules
gem 'rack-rewrite'
# active job backend
gem 'sucker_punch'
# sitemap
gem 'sitemap_generator'
# schedule cron jobs
gem 'whenever', require: false
# tagging
gem 'acts-as-taggable-on'
# obfuscate email addresses
gem 'actionview-encoded_mail_to'
# state machine
gem 'aasm'
# error reports
gem 'rollbar'
