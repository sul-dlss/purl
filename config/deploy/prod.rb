server 'sul-purl-prod-a.stanford.edu', user: 'purl', roles: %w(web db app)
server 'sul-purl-prod-b.stanford.edu', user: 'purl', roles: %w(web db app cron)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :bundle_without, %w{deployment development test}.join(' ')
