source 'https://rubygems.org'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.4'
# Use postgresql as the database for Active Record
gem 'pg'
# postgis adapter
gem 'activerecord-postgis-adapter'
# rgeo geojson module for encode/decode
gem 'rgeo-geojson'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# js helper utilities
gem 'underscore-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Advanced JS events with turbolinks
gem 'jquery-turbolinks'
# Parse CSS and add vendor prefixes to CSS rules using values from the Can I Use website
gem 'autoprefixer-rails', '~> 5.1.8.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
group :doc do
  gem 'sdoc', '~> 0.4.0'
end

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
group :development do
  gem 'spring'
  # open mail in browser
  gem 'letter_opener'
end

# use rspec and factory for tests
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do  
  gem 'faker'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
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
# for images
gem 'carrierwave'
gem 'mini_magick'