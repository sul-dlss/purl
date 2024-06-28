require 'find'

class PurlResource
  include ActiveModel::Model

  attr_accessor :id
  alias druid id

  class DruidNotValid < StandardError; end

  def self.all
    return [] unless Settings.document_cache_root
    return to_enum(:all) unless block_given?

    Find.find(Settings.document_cache_root) do |path|
      next unless path.ends_with?('public')

      druid = Dor::Util.druid_from_pair_tree(path)
      next unless druid

      yield PurlResource.find(druid)
    end
  end

  def self.find(id)
    raise DruidNotValid, id unless Dor::Util.validate_druid(id)

    PurlResource.new(id:)
  end

  def persisted?
    true
  end

  def version(version_id)
    version_id = 1 if version_id == :head # Until we have versions written to the disk, always use version 1
    PurlVersion.new(id:, version_id:).tap do |version|
      raise PurlVersion::ObjectNotReady, id unless version.ready?
    end
  end

  # Can be crawled / indexed by a crawler, e.g. Googlebot
  def crawlable?
    meta_json.fetch('sitemap')
  end

  def released_to_searchworks?
    meta_json.fetch('searchworks')
  end

  def released_to_earthworks?
    meta_json.fetch('earthworks')
  end

  def metrics
    metrics_service.get_metrics(druid)
  end

  # The meta.json contains the properties this purl is released to.
  delegate :meta_json_body, to: :resource_retriever

  def resource_retriever
    @resource_retriever ||= ResourceRetriever.new(druid:)
  end

  private

  def meta_json
    @meta_json ||= JSON.parse(meta_json_body) if meta_json_body.present?
  end

  def metrics_service
    @metrics_service ||= MetricsService.new
  end
end
