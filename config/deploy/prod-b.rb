server 'sul-purl-prod-b.stanford.edu', user: 'purl', roles: %w(web db app)
set :branch, 'sw-design'

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
