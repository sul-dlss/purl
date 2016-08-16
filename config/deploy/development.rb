server 'sul-purl-dev.stanford.edu', user: 'purl', roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'development'

set :bundle_without, %w{deployment test}.join(' ')
