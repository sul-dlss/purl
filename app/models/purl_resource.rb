# frozen_string_literal: true

class PurlResource
  include ActiveModel::Model

  attr_accessor :id
  alias druid id

  class DruidNotValid < StandardError; end

  def self.find(id)
    raise DruidNotValid, id unless Dor::Util.validate_druid(id)

    PurlResource.new(id:)
  end

  def persisted?
    true
  end

  def versions
    @versions = version_manifest&.fetch('versions', {})&.map do |version_id, version_attrs|
      PurlVersion
        .new(id:,
             version_id:,
             head: head_version == version_id.to_i,
             updated_at: version_attrs.fetch('date', nil),
             state: version_attrs.fetch('state'),
             resource_retriever: VersionedResourceRetriever.new(druid:, version_id:))
    end
  end

  def version(version_id)
    version_id = head_version if version_id == :head

    versions.find { |purl_version| purl_version.version_id == version_id.to_i }
  end

  def releases
    @releases ||= Releases.new(meta_json)
  end

  # The meta.json contains the properties this purl is released to.
  delegate :meta_json_body, :version_manifest_body, to: :resource_retriever

  def resource_retriever
    @resource_retriever ||= ResourceRetriever.new(druid:)
  end

  def meta_json
    @meta_json ||= JSON.parse(meta_json_body) if meta_json_body.present?
  end

  private

  def head_version
    @head_version = version_manifest&.fetch('head', 1).to_i
  end

  def version_manifest
    @version_manifest ||= JSON.parse(version_manifest_body)
  end
end
