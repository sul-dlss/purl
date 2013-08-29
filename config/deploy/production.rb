set :rails_env, "production"
set :deployment_host, "sul-purl-prod.stanford.edu"
set :bundle_without, [:deployment,:development,:test]
set :scm, :none
set :repository, "../"
set :deploy_via, :copy
role :web, deployment_host
role :app, deployment_host
role :db,  deployment_host, :primary => true
