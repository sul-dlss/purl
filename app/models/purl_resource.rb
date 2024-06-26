require 'find'

class PurlResource
  include ActiveModel::Model
  include ActiveSupport::Benchmarkable

  attr_accessor :id
  alias druid id

  class DruidNotValid < StandardError; end

  class ObjectNotReady < StandardError; end

  MODS_NS = 'http://www.loc.gov/mods/v3'.freeze

  def self.all
    return [] unless Settings.document_cache_root
    return to_enum(:all) unless block_given?

    Find.find(Settings.document_cache_root) do |path|
      next unless path.ends_with?('public')

      druid = Dor::Util.druid_from_pair_tree(path)
      next unless druid

      yield PurlResource.find(druid)
    rescue ObjectNotReady
      next
    end
  end

  def self.find(id)
    raise DruidNotValid, id unless Dor::Util.validate_druid(id)

    PurlResource.new(id:).tap do |obj|
      raise ObjectNotReady, id unless obj.ready?
    end
  end

  def self.storage_root_path
    Settings.document_cache_root
  end

  def mods?
    !!public_xml.mods
  end

  def ready?
    public_xml?
  end

  # Fetches the body of the public XML from the public_xml resource
  def public_xml_document
    @public_xml_document ||= Nokogiri::XML(public_xml_body)
  end

  def public_xml
    @public_xml ||= PublicXml.new(public_xml_document)
  end

  def meta_json
    @meta_json ||= JSON.parse(meta_json_body) if meta_json_body.present?
  end

  # @return [Array<String>] the identifiers of the collections this item is a member of
  def containing_collections
    @containing_collections ||= public_xml.relations('isMemberOfCollection')
  end

  # @return [Array<PurlResource>] the PURL resources of the collections this item is a member of
  def containing_purl_collections
    @containing_purl_collections ||= containing_collections.filter_map do |id|
      PurlResource.find(id)
    rescue ObjectNotReady, DruidNotValid
      nil
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

  delegate :rights_metadata, :object_type, :source_id, to: :public_xml

  def content_metadata
    @content_metadata ||= ContentMetadata.new(public_xml.content_metadata)
  end

  # @returns [Bool] are there resources that can be shown?
  # This prevents adding links to the embed service, when that service can't generate a valid response.
  def embeddable?
    content_metadata.resources.present?
  end

  # Show tracked downloads if the object has download permission and is a type that we track
  # If we can't track downloads (e.g. for WARC),or if it's a collection, no point in showing the download count
  def show_download_metrics?
    (rights.world_downloadable? || rights.stanford_only_downloadable?) &&
      %w[webarchive-seed webarchive-binary].exclude?(type) && !collection?
  end

  def rights
    @rights ||= RightsMetadata.new(rights_metadata)
  end

  def mods
    @mods ||= mods_display_object.mods_display_html&.presence
  end

  def iiif_manifest(**)
    @iiif_manifest ||= if iiif2_manifest?
                         iiif2_manifest(**)
                       else
                         iiif3_manifest(**)
                       end
  end

  def iiif2_manifest(**)
    @iiif2_manifest ||= IiifPresentationManifest.new(self, **)
  end

  def iiif2_manifest?
    if public_xml_document.at_xpath('/publicObject/contentMetadata[contains(@type,"image")
                                                                    or contains(@type,"map")
                                                                    or contains(@type,"book")]/resource[@type="image"]')
      true
    elsif public_xml_document.at_xpath('/publicObject/contentMetadata[@type="book"]/resource[@type="page"]')
      true
    else
      false
    end
  end

  def iiif3_manifest(**)
    @iiif3_manifest ||= Iiif3PresentationManifest.new(self, **)
  end

  def collection?
    object_type == 'collection'
  end

  def collection_items_link
    "#{Settings.searchworks.url}/catalog?f[collection][]=#{folio_instance_hrid || druid}"
  end

  def schema_dot_org?
    ::Metadata::SchemaDotOrg.schema_type?(cocina_body)
  end

  def metrics
    metrics_service.get_metrics(druid)
  end

  concerning :Metadata do
    def title
      if mods?
        Array.wrap(mods.title).join(' -- ')
      else
        public_xml.title
      end
    end

    def description
      return unless mods?

      @description ||= begin
        abstract = mods.abstract.detect { |a| a.respond_to? :values }
        if abstract
          abstract.values.join.strip
        else
          ''
        end
      end
    end

    def type
      @type ||= content_metadata.type
    end

    def copyright?
      copyright.present?
    end

    def copyright
      rights.copyright_statement
    end

    def use_and_reproduction?
      use_and_reproduction.present?
    end

    def use_and_reproduction
      rights.use_and_reproduction_statement
    end

    delegate :catalog_key, :folio_instance_hrid, to: :public_xml

    def representative_thumbnail?
      representative_thumbnail.present?
    end

    def representative_thumbnail
      "#{iiif_manifest.thumbnail_base_uri}/full/!400,400/0/default.jpg" if iiif_manifest.thumbnail_base_uri.present?
    end

    # @return [String,nil] DOI (with https://doi.org/ prefix) if present
    def doi
      @doi ||= mods_ng_document.at_xpath('mods:identifier[@type="doi"]', mods: MODS_NS)&.text
    end

    # @return [String,nil] DOI (without https://doi.org/ prefix) if present
    def doi_id
      doi&.delete_prefix('https://doi.org/')
    end

    def related_item_elements
      @related_item_elements ||= mods_ng_document.xpath('mods:relatedItem', mods: MODS_NS)
    end

    def publication_date
      @publication_date ||= ::Metadata::PublicationDate.call(mods_ng_document)
    end

    def authors
      @authors ||= ::Metadata::Authors.call(mods_ng_document)
    end

    def schema_dot_org
      ::Metadata::SchemaDotOrg.call(cocina_body)
    end
  end

  concerning :Caching do
    def cache_key
      "purl_resource/druid:#{id}"
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

    def last_modified_header_value
      t = public_xml_resource.header[:last_modified]

      if t.is_a? String
        Time.zone.parse(t)
      else
        t
      end
    rescue ArgumentError => e
      Rails.logger.info("Unable to parse last modified time: #{e}")
      Time.zone.now
    end
  end

  concerning :ActiveModelness do
    def attributes
      {
        druid: id,
        druid_tree:,
        root_path: self.class.storage_root_path
      }
    end

    def persisted?
      true
    end

    private

    def true_targets
      meta_json.fetch('true_targets')
    end

    def druid_tree
      Dor::Util.create_pair_tree(druid) || druid
    end
  end

  concerning :Fetching do
    def cache_resource(key, &block)
      if Settings.resource_cache.enabled
        Rails.cache.fetch("#{cache_key}/#{key}", expires_in: Settings.resource_cache.lifetime, &block)
      else
        yield
      end
    end

    def public_xml_resource
      @public_xml_resource ||= cache_resource(:public_xml) do
        fetch_resource(:public_xml, Settings.purl_resource.public_xml)
      end
    end

    def public_xml_body
      public_xml_resource.body if public_xml_resource.success?
    end

    def meta_json_resource
      @meta_json_resource ||= cache_resource(:meta) do
        fetch_resource(:meta, Settings.purl_resource.meta)
      end
    end

    def meta_json_body
      meta_json_resource.body if meta_json_resource.success?
    end

    def public_xml?
      public_xml_body.present?
    end

    def cocina_body
      @cocina_body ||= begin
        resource = cache_resource(:cocina) do
          fetch_resource(:cocina, Settings.purl_resource.cocina)
        end
        resource.body if resource.success?
      end
    end

    def cocina?
      cocina_body.present?
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
  end

  private

  def mods_display_object
    @mods_display_object ||= ModsDisplay::Record.new(public_xml.mods.to_xml)
  end

  def mods_ng_document
    @mods_ng_document ||= public_xml.mods
  end

  def logger
    Rails.logger
  end

  def metrics_service
    @metrics_service ||= MetricsService.new
  end
end
