server 'sul-purl-stage.stanford.edu', user: 'purl', roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
set :bundle_without, %w{deployment test}.join(' ')
