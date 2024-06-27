require 'find'

class PurlResource
  include ActiveModel::Model
  include ActiveSupport::Benchmarkable

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
    return meta_json['sitemap'] if meta_json.key?('sitemap')

    # This is for handling the older format of meta.json
    true_targets.include?('PURL sitemap')
  end

  def released_to_searchworks?
    return meta_json['searchworks'] if meta_json.key?('searchworks')

    # This is for handling the older format of meta.json
    true_targets.include?('Searchworks')
  end

  def released_to_earthworks?
    return meta_json['earthworks'] if meta_json.key?('earthworks')

    # This is for handling the older format of meta.json
    true_targets.include?('Earthworks')
  end

  def metrics
    metrics_service.get_metrics(druid)
  end

  # For building links in _find_it.html.erb
  def attributes
    {
      druid:,
      druid_tree:,
      root_path: self.class.storage_root_path
    }
  end

  private

  def meta_json
    @meta_json ||= JSON.parse(meta_json_body) if meta_json_body.present?
  end

  def meta_json_resource
    @meta_json_resource ||= Rails.cache.fetch("#{druid}/meta", expires_in: Settings.resource_cache.lifetime) do
      fetch_resource(:meta, Settings.purl_resource.meta)
    end
  end

  def self.storage_root_path
    Settings.document_cache_root
  end

  def fetch_resource(key, value)
    url_or_path = value % attributes

    benchmark "Fetching #{id} #{key} at #{url_or_path}" do
      case url_or_path
      when /^http/
        Faraday.get(url_or_path)
      else
        DocumentCacheResource.new(url_or_path)
      end
    end
  end

  def logger
    Rails.logger
  end

  def meta_json_body
    meta_json_resource.body if meta_json_resource.success?
  end

  def true_targets
    meta_json.fetch('true_targets')
  end

  def druid_tree
    Dor::Util.create_pair_tree(druid) || druid
  end

  def metrics_service
    @metrics_service ||= MetricsService.new
  end
end
