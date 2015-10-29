set :application, 'purl'
set :repo_url, 'https://github.com/sul-dlss/purl.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/opt/app/purl/purl'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/secrets.yml config/database.yml config/initializers/squash_exceptions.rb public/robots.txt)

# Default value for linked_dirs is []
set :linked_dirs, %w(config/settings log tmp/pids tmp/cache tmp/sockets vendor/bundle public/sitemaps public/system)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

before 'deploy:publishing', 'squash:write_revision'

namespace :sitemaps do
  task :create_symlink do
    on roles(:web) do |h|
      execute "ln -s #{release_path}/public/sitemaps/sitemap.xml #{release_path}/public/sitemap.xml"
    end
  end
end

before 'deploy:published', 'sitemaps:create_symlink'
