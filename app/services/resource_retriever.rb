class ResourceRetriever
  class ResourceNotFound < StandardError; end

  def initialize(druid:)
    @druid = druid
  end

  def public_xml_body
    public_xml_resource.body if public_xml_resource.success?
  end

  def meta_json_body
    meta_json_resource.body if meta_json_resource.success?
  end

  def cocina_body
    cocina_resource.body if cocina_resource.success?
  end

  def version_manifest_body
    raise ResourceNotFound, 'Unable to retrieve version manifest' unless version_manifest_resource.success?

    version_manifest_resource.body
  end

  def updated_at
    if public_xml_resource.respond_to? :updated_at
      public_xml_resource.updated_at
    elsif public_xml_resource.respond_to?(:header) && public_xml_resource.header[:last_modified].present?
      last_modified_header_value
    else
      Time.zone.now
    end
  end

  private

  attr_reader :druid

  def attributes
    {
      druid:,
      druid_tree:
    }
  end

  def resource_cache
    @resource_cache ||= ResourceCache.new
  end

  def druid_tree
    Dor::Util.create_pair_tree(druid) || druid
  end

  def cache_prefix
    "purl_resource/druid:#{druid}"
  end

  def cache_key(key)
    [cache_prefix, key].join('/')
  end

  def meta_json_path
    Settings.purl_resource.versioned.meta % attributes
  end

  def version_manifest_path
    Settings.stacks.version_manifest_path % attributes
  end

  def meta_json_resource
    @meta_json_resource ||= resource_cache.get(meta_json_path, cache_key(:meta))
  end

  def version_manifest_resource
    @version_manifest_resource ||= resource_cache.get(version_manifest_path, cache_key(:version_manifest))
  end

  def last_modified_header_value
    t = public_xml_resource.header[:last_modified]

    if t.is_a? String
      Time.zone.parse(t)
    else
      t
    end
  rescue ArgumentError => e
    logger.info("Unable to parse last modified time: #{e}")
    Time.zone.now
  end
end
