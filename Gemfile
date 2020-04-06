source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use sqlite3 as the database (during local development)
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# A gem for simple rails environment specific config
gem 'config'
# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# CanCanCan is an authorization Gem for rails
gem 'cancancan'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Honeybadger for exception reporting
gem 'honeybadger'

# Use okcomputer to monitor the application
gem 'okcomputer'

gem 'mods_display', '~> 0.4'
gem 'htmlentities'
gem 'dor-rights-auth'
gem 'bootstrap-sass'
gem 'faraday'
gem 'addressable'
gem 'tophat'
gem 'rails-file-icons'
gem 'sul_styles', '~> 0.3'

# sul-dlss/osullivan#development has early support for generating IIIF v3 manifests
gem 'iiif-presentation', github: 'sul-dlss/osullivan', branch: 'development'
gem 'dalli'

group :production do
  gem 'newrelic_rpm'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # RSpec for testing
  gem 'rspec-rails', '~> 3.0'

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
