# frozen_string_literal: true

class VersionedResourceRetriever < ResourceRetriever
  include ActiveSupport::Benchmarkable

  def initialize(druid:, version_id:)
    super(druid:)
    @version_id = version_id
  end

  private

  attr_reader :version_id

  def attributes
    super.merge(version_id:)
  end

  def cache_key(key)
    [cache_prefix, version_id, key].join('/')
  end

  def public_xml_path
    Settings.purl_resource.versioned.public_xml
  end

  def meta_json_path
    Settings.purl_resource.versioned.meta
  end

  def cocina_path
    Settings.purl_resource.versioned.cocina
  end
end
