source 'https://rubygems.org'

gem 'rails', '4.2.3'
gem 'mods_display', '~> 0.3.2'
gem 'htmlentities'
gem 'dor-rights-auth'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'json'

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'simplecov'
end

gem 'execjs'
gem 'therubyracer', platforms: :ruby

group :development do
  gem 'sqlite3'
end

group :testing, :production do
  gem 'mysql2'
end

# Gems used only for assets and not required
# in production environments by default.

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'lyberteam-capistrano-devel'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
end

gem 'rails_config'

gem 'squash_ruby', require: 'squash/ruby'
gem 'squash_rails', '1.3.3', require: 'squash/rails'
