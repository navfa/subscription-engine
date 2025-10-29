# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'pg'
gem 'puma'

group :development, :test do
  gem 'debug'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 7.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false
  gem 'webmock'
end
