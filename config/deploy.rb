require 'net/ssh/kerberos'
require 'bundler/setup'
require 'bundler/capistrano'
require 'dlss/capistrano'
require 'pathname'

set :application, "purl"
set :stages, %W(testing production)
set :default_stage, "testing"
set :bundle_flags, "--quiet"
set :deploy_via, :copy

require 'capistrano/ext/multistage'

set :shared_children, %w(
  log
  config/database.yml
  config/environments
)

set :user, "lyberadmin"
set :runner, "lyberadmin"
set :ssh_options, {
  :auth_methods  => %w(gssapi-with-mic publickey hostbased),
  :forward_agent => true
}

set :destination, "/home/lyberadmin"


#set :copy_cache, true
set :copy_exclude, [".git"]
set :use_sudo, false
set :keep_releases, 2

set :deploy_to, "#{destination}/#{application}"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

#after "deploy", "deploy:migrate"
after "deploy:update", "deploy:cleanup" 
