source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

gem 'webpacker', '~> 5.x'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# A gem for simple rails environment specific config
gem 'config'

# CanCanCan is an authorization Gem for rails
gem 'cancancan'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Honeybadger for exception reporting
gem 'honeybadger'

# Use okcomputer to monitor the application
gem 'okcomputer'

gem 'mods_display', '~> 1.0.0.alpha1'
gem 'htmlentities'
gem 'dor-rights-auth', '~> 1.6'
gem 'bootstrap'
gem 'faraday'
gem 'addressable'
gem 'tophat'
gem 'rails-file-icons'
gem 'sul_styles', '~> 0.6'

# Use recaptcha gem to prevent robots spamming the feedback form
gem 'recaptcha'

# sul-dlss/osullivan#development has early support for generating IIIF v3 manifests
gem 'iiif-presentation', github: 'sul-dlss/osullivan', branch: 'development'
gem 'dalli'

# connection_pool required for thread-safe operations in dalli >= 3.0
# see https://github.com/petergoldstein/dalli/blob/v3.0.0/3.0-Upgrade.md
gem 'connection_pool'

group :production do
  gem 'newrelic_rpm'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  # RSpec for testing
  gem 'rspec-rails', '~> 5.0'

  # Capybara for feature/integration tests
  gem 'capybara'

  gem 'selenium-webdriver', '!= 3.13.0'
  gem 'webdrivers'

  # Rubocop is a static code analyzer to enforce style.
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # scss_lint will test the scss files to enfoce styles
  gem 'scss_lint', require: false

  gem 'simplecov', require: false
end

gem 'lograge'

# Use Capistrano for deployment
group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end
