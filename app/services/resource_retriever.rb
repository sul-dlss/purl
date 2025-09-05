# frozen_string_literal: true

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

  def druid_path
    File.join(Settings.stacks.root, "#{druid_tree}/#{druid}/versions")
  end

  private

  attr_reader :druid

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
    File.join(druid_path, 'meta.json')
  end

  def version_manifest_path
    File.join(druid_path, 'versions.json')
  end

  def meta_json_resource
    @meta_json_resource ||= resource_cache.get(meta_json_path, cache_key(:meta))
  end

  def version_manifest_resource
    @version_manifest_resource ||= resource_cache.get(version_manifest_path, cache_key(:version_manifest))
  end
end
