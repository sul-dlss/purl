TEST_DRUID = 'pv954fv1448' # in both purl/stacks prod and purl/stacks test

Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  h.check :directory, path: Settings.document_cache_root

  # Check the memcache servers used by Rails.cache if using the DalliStore implementation
  h.check :dalli, cache: Rails.cache if defined?(ActiveSupport::Cache::DalliStore) && Rails.cache.is_a?(ActiveSupport::Cache::DalliStore)

  # seems self-referential, but tells us if public_xml is working
  public_xml_url = Settings.purl_resource.public_xml.sub('%{druid}', TEST_DRUID)
  public_xml_url = Settings.purl_resource.public_xml.sub('%{druid_tree}', TEST_DRUID) if public_xml_url.match(/druid/)
  h.check :url, get: public_xml_url

  h.check :non_crucial do |status|
    # seems self-referential, but tells us if mods is working
    mods_url = Settings.purl_resource.mods.sub('%{druid}', TEST_DRUID)
    mods_url = Settings.purl_resource.mods.sub('%{druid_tree}', TEST_DRUID) if mods_url.match(/druid/)
    non_crucial_url_check(mods_url, status, 'MODS available')
  end

  h.check :non_crucial do |status|
    iiif_manifest_url = Settings.purl_resource.iiif_manifest.sub('%{druid}', TEST_DRUID)
    non_crucial_url_check(iiif_manifest_url, status, 'IIIF manifests available')
  end
  # NOTE: Settings.stacks.iiif_profile is a static service to tell services what renderer to use for IIIF
  #  and therefore doesn't need to be considered a dependency here

  h.check :non_crucial do |status|
    non_crucial_url_check(Settings.stacks.url, status, 'Object content accessed here')
  end

  h.check :non_crucial do |status|
    resource_url = Settings.embed.url.sub('%{druid}', TEST_DRUID)
    non_crucial_url_check(Settings.embed.iframe.url_template.sub('{?url*}', "?url=#{resource_url}"), status, 'OEmbed service')
  end

  h.check :non_crucial do |status|
    non_crucial_url_check("#{Settings.searchworks.url}#{TEST_DRUID}", status, 'For "View in SearchWorks" link')
  end

  h.check :non_crucial do |status|
    non_crucial_action_mailer_check(FeedbackMailer, status, 'For Feedback link')
  end

  h.check :non_crucial do |status|
    non_crucial_url_check(Settings.flipbook.url, status, 'For Flipbook presentation')
  end
end

# even if url doesn't return 2xx or 304, return status 200 here
#  (for load-balancer check) but expose failure in message text (for nagios check and humans)
def non_crucial_url_check(url, return_status, info)
  non_crucial_status = IsItWorking::Status.new('')
  IsItWorking::UrlCheck.new(get: url).call(non_crucial_status)
  non_crucial_status.messages.each do |x|
    return_status.ok "#{'FAIL: ' unless x.ok?}#{x.message} (#{info})"
  end
end

# even if mailer isn't accepting connections on port 25, return status 200 here
#  (for load-balancer check) but expose failure in message text (for nagios check and humans)
def non_crucial_action_mailer_check(klass, return_status, info)
  non_crucial_status = IsItWorking::Status.new('')
  IsItWorking::ActionMailerCheck.new(class: klass).call(non_crucial_status)
  non_crucial_status.messages.each do |x|
    return_status.ok "#{'FAIL: ' unless x.ok?}#{x.message} (#{info})"
  end
end
