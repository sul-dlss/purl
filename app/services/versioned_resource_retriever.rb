# frozen_string_literal: true

class VersionedResourceRetriever < ResourceRetriever
  def initialize(druid:, version_id:)
    super(druid:)
    @version_id = version_id
  end

  private

  attr_reader :version_id

  def attributes
    super.merge({ version_id: })
  end

  def cache_key(key)
    [cache_prefix, version_id, key].join('/')
  end

  def public_xml_resource
    @public_xml_resource ||= resource_cache.get(public_xml_path, cache_key(:public_xml))
  end

  def cocina_resource
    @cocina_resource ||= resource_cache.get(cocina_path, cache_key(:cocina))
  end

  def public_xml_path
    Settings.purl_resource.versioned.public_xml % attributes
  end

  def cocina_path
    Settings.purl_resource.versioned.cocina % attributes
  end
end
