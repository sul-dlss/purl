source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'addressable'
gem 'bootsnap', '>= 1.1.0', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'cancancan' # authorization
gem 'config' # simple rails environment specific config
gem 'faraday' # HTTP client
gem 'honeybadger' # exception reporting
gem "importmap-rails" # Use JavaScript with ESM import maps
gem "jbuilder" # Build JSON APIs with ease
gem "jsonpath"
gem 'okcomputer' # application monitoring
gem "propshaft"
gem "puma", "~> 6.0" # web server for development
gem "rails", "~> 7.1.0"
gem 'recaptcha' # prevent robots spamming the feedback form
gem "sitemap_generator"
gem "stimulus-rails" # Hotwire's modest JavaScript framework
gem 'tophat'
gem "turbo-rails" # Hotwire's SPA-like page accelerator
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "view_component"
gem 'whenever', require: false # cron jobs

# DLSS and its community
gem 'dor-rights-auth', '~> 1.6'
gem 'iiif-presentation', '~> 1.3'
gem 'mods_display', '~> 1.5'

group :production do
  gem 'newrelic_rpm'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'capybara' # for feature/integration tests
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  gem 'rspec-rails', '~> 6.0'

  # Rubocop is a static code analyzer (linter) to enforce style.
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false

  gem 'selenium-webdriver', '!= 3.13.0'
  gem 'simplecov', require: false
  gem 'webmock', '~> 3.19'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end
