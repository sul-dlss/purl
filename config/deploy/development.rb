server 'sul-purl-dev.stanford.edu', user: 'lyberadmin', roles: %w{web db app}

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "development"
