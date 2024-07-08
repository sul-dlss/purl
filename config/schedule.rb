# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
require_relative 'environment'

Config.load_and_set_settings(Config.setting_files('config', 'production'))

# These define jobs that checkin with Honeybadger.
# If changing the schedule of one of these jobs, also update at https://app.honeybadger.io/projects/54415/check_ins
job_type :rake_hb, 'cd :path && :environment_variable=:environment bundle exec rake --silent ":task" :output && curl --silent https://api.honeybadger.io/v1/check_in/:check_in'

every :month, roles: [:cron] do
  set :check_in, Settings.honeybadger_checkins.sitemap
  rake_hb "sitemap:refresh:no_ping" # pinging Google is deprecated
end
