class ResourceRetriever
  include ActiveSupport::Benchmarkable

  def initialize(druid:, version_id: nil)
    @druid = druid
    @version_id = version_id
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
    version_manifest_resource.body if version_manifest_resource.success?
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

  attr_reader :druid, :version_id

  def attributes
    {
      druid:,
      druid_tree:,
      root_path:,
      version_id:
    }
  end

  def root_path
    Settings.document_cache_root
  end

  def druid_tree
    Dor::Util.create_pair_tree(druid) || druid
  end

  def cache_resource(key, &)
    if Settings.resource_cache.enabled
      Rails.cache.fetch(cache_key(key), expires_in: Settings.resource_cache.lifetime, &)
    else
      yield
    end
  end

  def cache_key(key)
    prefix = "purl_resource/druid:#{druid}"
    version_id ? "#{prefix}/#{version_id}/#{key}" : "#{prefix}/#{key}"
  end

  def versioned_layout?
    version_manifest_resource.success?
  end

  def public_xml_path
    return Settings.purl_resource.versioned.public_xml if versioned_layout?

    Settings.purl_resource.public_xml
  end

  def meta_json_path
    return Settings.purl_resource.versioned.meta if versioned_layout?

    Settings.purl_resource.meta
  end

  def cocina_path
    return Settings.purl_resource.versioned.cocina if versioned_layout?

    Settings.purl_resource.cocina
  end

  def public_xml_resource
    @public_xml_resource ||= cache_resource(:public_xml) do
      fetch_resource(:public_xml, public_xml_path)
    end
  end

  def meta_json_resource
    @meta_json_resource ||= cache_resource(:meta) do
      fetch_resource(:meta, meta_json_path)
    end
  end

  def cocina_resource
    @cocina_resource ||= cache_resource(:cocina) do
      fetch_resource(:cocina, cocina_path)
    end
  end

  def version_manifest_resource
    @version_manifest_resource ||= cache_resource(:version_manifest) do
      fetch_resource(:version_manifest, Settings.stacks.version_manifest_path)
    end
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

  def logger
    Rails.logger
  end

  def fetch_resource(key, value)
    url_or_path = value % attributes

    benchmark "Fetching #{druid} #{key} at #{url_or_path}" do
      case url_or_path
      when /^http/
        Faraday.get(url_or_path)
      else
        DocumentCacheResource.new(url_or_path)
      end
    end
  end
end
