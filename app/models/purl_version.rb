# frozen_string_literal: true

require 'find'

class PurlVersion # rubocop:disable Metrics/ClassLength
  include ActiveModel::Model
  include ActiveSupport::Benchmarkable

  attr_accessor :id, :head, :state, :resource_retriever
  attr_reader :version_id, :updated_at
  alias druid id

  class DruidNotValid < StandardError; end

  class ObjectNotReady < StandardError; end

  MODS_NS = 'http://www.loc.gov/mods/v3'

  def persisted?
    true
  end

  def head?
    head
  end

  def withdrawn?
    state == 'withdrawn'
  end

  # Coerce version IDs to integers
  def version_id=(value)
    @version_id = value.to_i
  end

  def updated_at=(value)
    @updated_at = value&.to_datetime
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

  # @return [Array<String>] the identifiers of the collections this item is a member of
  def containing_collections
    @containing_collections ||= public_xml.relations('isMemberOfCollection')
  end

  # @return [Array<Array>] a list of PURL resources, PurlVersion tuples of the collections this item is a member of
  def containing_purl_collections
    @containing_purl_collections ||= containing_collections.filter_map do |id|
      resource = PurlResource.find(id)
      return nil unless resource.version(:head).ready?

      [resource, resource.version(:head)]
    rescue ResourceRetriever::ResourceNotFound => e
      Honeybadger.notify(e)
      nil
    end
  end

  def content_metadata
    @content_metadata ||= ContentMetadata.new(public_xml.content_metadata)
  end

  def structural_metadata
    @structural_metadata ||= StructuralMetadata.new(cocina['structural'])
  end

  # @returns [Bool] are there resources that can be shown?
  # This prevents adding links to the embed service, when that service can't generate a valid response.
  def embeddable?
    structural_metadata.resources.present?
  end

  # Show tracked downloads if the object has download permission and is a type that we track
  # If we can't track downloads (e.g. for WARC),or if it's a collection, no point in showing the download count
  def show_download_metrics?
    download_status = cocina.dig('access', 'download')
    # rubocop:disable Style/MultipleComparison
    (download_status == 'world' || download_status == 'stanford') &&
      %w[webarchive-seed webarchive-binary].exclude?(type) && !collection?
    # rubocop:enable Style/MultipleComparison
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
    return false if collection?

    resource_types = structural_metadata.resources.map(&:type)
    if (image? || book? || map?) &&
       (structural_metadata.virtual_object? || resource_types.include?('https://cocina.sul.stanford.edu/models/resources/image'))
      true
    else
      book? && resource_types.include?('https://cocina.sul.stanford.edu/models/resources/page')
    end
  end

  def iiif3_manifest(**)
    @iiif3_manifest ||= Iiif3PresentationManifest.new(self, **)
  end

  def collection?
    cocina['type'] == 'https://cocina.sul.stanford.edu/models/collection'
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

  concerning :Metadata do # rubocop:disable Metrics/BlockLength
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
      @type ||= cocina['type']
    end

    def book?
      type == 'https://cocina.sul.stanford.edu/models/book'
    end

    def image?
      type == 'https://cocina.sul.stanford.edu/models/image'
    end

    def map?
      type == 'https://cocina.sul.stanford.edu/models/map'
    end

    def geo?
      type == 'https://cocina.sul.stanford.edu/models/geo'
    end

    def three_d?
      type == 'https://cocina.sul.stanford.edu/models/3d'
    end

    def object?
      type == 'https://cocina.sul.stanford.edu/models/object'
    end

    def copyright?
      copyright.present?
    end

    def copyright
      cocina['access']['copyright']
    end

    def use_and_reproduction?
      use_and_reproduction.present?
    end

    def use_and_reproduction
      cocina.dig('access', 'useAndReproductionStatement')
    end

    def folio_instance_hrid
      @folio_instance_hrid ||= cocina['identification']['catalogLinks']
                               .find { it['catalog'] == 'folio' }&.fetch('catalogRecordId')
    end

    def catalog_key
      @catalog_key ||= folio_instance_hrid&.delete_prefix('a')
    end

    def representative_thumbnail?
      representative_thumbnail.present?
    end

    def representative_thumbnail
      "#{iiif_manifest.thumbnail_base_uri}/full/!400,400/0/default.jpg" if iiif_manifest.thumbnail_base_uri.present?
    end

    # @return [String,nil] DOI (with https://doi.org/ prefix) if present
    def doi
      @doi ||= begin
        val = JsonPath.new('$.identification.doi').first(cocina) ||
              JsonPath.new("$.description.identifier[?(@['type'] == 'doi')].value").first(cocina) ||
              JsonPath.new("$.description.identifier[?(@['uri'] =~ /doi/)].uri").first(cocina)
        if val
          val.start_with?('https://doi.org/') ? val : "https://doi.org/#{val}"
        end
      end
    end

    # @return [String,nil] DOI (without https://doi.org/ prefix) if present
    def doi_id
      doi&.delete_prefix('https://doi.org/')
    end

    def publication_date
      @publication_date ||= begin
        admin_metadata = cocina['description']['adminMetadata']

        creation_event = admin_metadata && admin_metadata['event']&.find { |node| node['type'] == 'creation' }

        if creation_event && (matcher = creation_event['date'].first['value'].match(/(\d{4})/))
          matcher[1]
        end
      end
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
      "purl_resource/druid:#{druid}/#{version_id}"
    end
  end

  delegate :public_xml_body, :cocina_body, to: :resource_retriever

  def public_xml?
    public_xml_body.present?
  end

  def cocina?
    cocina_body.present?
  end

  def cocina
    @cocina ||= JSON.parse(cocina_body)
  end

  def mods_display_object
    @mods_display_object ||= ModsDisplay::Record.new(public_xml.mods.to_xml)
  end

  def mods_ng_document
    @mods_ng_document ||= public_xml.mods
  end

  def metrics_service
    @metrics_service ||= MetricsService.new
  end

  # @param [ResourceFile]
  def cocina_file_for_resource(resource)
    if druid == resource.druid
      cocina_file(resource.filename)
    else
      external_file(resource.druid, resource.filename)
    end
  end

  def cocina_file(filename)
    structural_metadata.find_file_by_filename(filename)
  end

  private

  def external_file(external_druid, filename)
    external_cocina = PurlResource.find(external_druid).version(:head)
    external_cocina.cocina_file(filename)
  rescue ResourceRetriever::ResourceNotFound
    Honeybadger.notify("External resource not found for druid: #{druid} and filename: #{filename} on #{druid}")
    nil
  end
end
