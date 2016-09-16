require 'okcomputer'

# /status for 'upness', e.g. for load balancer
# /status/all to show all dependencies
# /status/<name-of-check> for a specific check (e.g. for nagios warning)
OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true
OkComputer::Registry.deregister "database" # don't check (unused) ActiveRecord database conn

# TODO: remove DirectoryCheck here after there is comparable functionality in okcomputer
class DirectoryCheck < OkComputer::Check
  attr_reader :path, :options
  def initialize(path, options = {})
    @path = Pathname(path.to_s)
    @options = options
  end

  def check
    mark_message "Directory check for #{path}: #{options.inspect}"
    mark_failure if options[:read] && !path.readable?
    mark_failure if options[:write] && !path.writable?
  end
end

# Check if a mail server is responding.
# TODO: remove ActionMailerCheck here after there is comparable functionality in okcomputer
class ActionMailerCheck < OkComputer::Check
  attr_reader :klass, :timeout_secs
  def initialize(klass, timeout_secs = 2)
    @klass = klass || ActionMailer::Base
    @timeout_secs = timeout_secs
  end
  def check
    host = klass.smtp_settings[:address]
    port = klass.smtp_settings[:port] || 'smtp'
    begin
      ping(host, port, timeout_secs)
      mark_message "#{klass} is accepting connections on port #{port}"
    rescue Errno::ECONNREFUSED
      mark_message "#{klass} is not accepting connections on port #{port}"
      mark_failure
    rescue SocketError => e
      mark_message "connection to #{klass} on port #{port} failed with '#{e.message}'"
      mark_failure
    rescue TimeoutError
      mark_message "#{klass} did not respond on port #{port} within #{timeout_secs} seconds"
      mark_failure
    rescue e
      mark_message "connection to #{klass} on port #{port} failed with '#{e.message}'"
      mark_failure
    end
  end

  def ping(host, port, timeout_secs)
    timeout(timeout_secs) do
      s = TCPSocket.new(host, port)
      s.close
    end
    true
  end
end

# REQUIRED checks, required to pass for /status/all
#  individual checks also avail at /status/<name-of-check>
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

OkComputer::Registry.register 'document_cache_root',
  DirectoryCheck.new(Settings.document_cache_root, read: true, write: true)

# Check the memcache servers used by Rails.cache
if Rails.cache.respond_to? :stats
  OkComputer::Registry.register 'rails_cache', OkComputer::CacheCheck.new
else
  OkComputer::Registry.register 'rails_cache', OkComputer::GenericCacheCheck.new
end

# NOTE:
# Settings.purl_resource.public_xml, Settings.purl_resource.mods, and Settings.purl_resource.iiif_manifest
#   exist in the document cache root on deployed environments.
# The document cache root check should be sufficient for these.

# NOTE: Settings.stacks.iiif_profile is a static service to tell services what renderer to use for IIIF
#  and therefore doesn't need to be considered a dependency here

# ------------------------------------------------------------------------------

# NON-CRUCIAL (Optional) checks, avail at /status/<name-of-check>
#   - at individual endpoint, HTTP response code reflects the actual result
#   - in /status/all, these checks will display their result text, but will not affect HTTP response code
OkComputer::Registry.register 'stacks_service', OkComputer::HttpCheck.new(Settings.stacks.url)

# OEmbed service
TEST_DRUID = 'pv954fv1448' # in both purl/stacks prod and purl/stacks test
resource_url = Settings.embed.url.sub('%{druid}', TEST_DRUID)
OkComputer::Registry.register 'embed_service',
  OkComputer::HttpCheck.new(Settings.embed.iframe.url_template.sub('{?url*}', "?url=#{resource_url}"))

OkComputer::Registry.register 'feedback_mailer', ActionMailerCheck.new(FeedbackMailer)

# TODO: When SW has a more benign endpoint for up-ness checks, we should use that.
#  For now, concerned about hammering SearchWorks with pings, as these will all hit the Solr index.
#  This is minor functionality for purl -- "View in SearchWorks" link
#OkComputer::Registry.register 'searchworks', OkComputer::HttpCheck.new("#{Settings.searchworks.url}#{TEST_DRUID}")

OkComputer.make_optional %w(stacks_service embed_service feedback_mailer)
