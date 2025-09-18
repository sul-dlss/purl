# frozen_string_literal: true

class ResourceRetriever
  class ResourceNotFound < StandardError; end

  def initialize(druid:)
    @druid = druid
  end

  def meta_json_body
    @meta_json_body ||= meta_json_resource.read
  end

  def version_manifest_body
    @version_manifest_body ||= version_manifest_resource.read
  rescue Errno::ENOENT
    raise ResourceNotFound, 'Unable to retrieve version manifest'
  end

  def druid_path
    File.join(Settings.stacks.root, "#{druid_tree}/#{druid}/versions")
  end

  private

  attr_reader :druid

  def druid_tree
    Dor::Util.create_pair_tree(druid) || druid
  end

  def meta_json_path
    File.join(druid_path, 'meta.json')
  end

  def version_manifest_path
    File.join(druid_path, 'versions.json')
  end

  def meta_json_resource
    @meta_json_resource ||= File.open(meta_json_path)
  end

  def version_manifest_resource
    @version_manifest_resource ||= File.open(version_manifest_path)
  end
end
