require 'okcomputer'
require 'timeout'

# /status for 'upness', e.g. for load balancer
# /status/all to show all dependencies
# /status/<name-of-check> for a specific check (e.g. for nagios warning)
OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true
OkComputer::Registry.deregister "database" # don't check (unused) ActiveRecord database conn

# REQUIRED checks, required to pass for /status/all
#  individual checks also avail at /status/<name-of-check>
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

ActiveSupport.on_load(:action_controller) do
  OkComputer::Registry.register 'feedback_mailer', OkComputer::ActionMailerCheck.new(FeedbackMailer)

  # TODO: When SW has a more benign endpoint for up-ness checks, we should use that.
  #  For now, concerned about hammering SearchWorks with pings, as these will all hit the Solr index.
  #  This is minor functionality for purl -- "View in SearchWorks" link
  #OkComputer::Registry.register 'searchworks', OkComputer::HttpCheck.new("#{Settings.searchworks.url}#{TEST_DRUID}")

  OkComputer.make_optional %w(feedback_mailer)
end
