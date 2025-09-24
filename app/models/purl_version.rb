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

  # @return [Array<Array>] a list of PURL resources, PurlVersion tuples of the collections this item is a member of
  def containing_purl_collections
    @containing_purl_collections ||= containing_collections.filter_map do |id|
      resource = PurlResource.find(id)
      return nil unless resource.version(:head).ready?

      [resource, resource.version(:head)]
    rescue ResourceRetriever::ResourceNotFound
      # The collection is not available, likely because it is "dark"
      nil
    end
  end

  def structural_metadata
    @structural_metadata ||= StructuralMetadata.new(druid:, json: cocina['structural'])
  end

  delegate :containing_collections, to: :structural_metadata
  delegate :collection?, :webarchive_seed?, :webarchive_binary?, to: :item_type

  # @returns [Bool] are there resources that can be shown?
  # This prevents adding links to the embed service, when that service can't generate a valid response.
  def embeddable?
    structural_metadata.resources.present? || structural_metadata.virtual_object?
  end

  # Show tracked downloads if the object has download permission and is a type that we track
  # If we can't track downloads (e.g. for WARC),or if it's a collection, no point in showing the download count
  def show_download_metrics?
    download_status = cocina.dig('access', 'download')
    %w[world stanford].include?(download_status) &&
      !webarchive_seed? && !webarchive_binary? && !collection?
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

    resource_types = structural_metadata.file_sets.map(&:type)
    if (item_type.image? || item_type.book? || item_type.map?) &&
       (structural_metadata.virtual_object? || resource_types.include?('https://cocina.sul.stanford.edu/models/resources/image'))
      true
    else
      item_type.book? && resource_types.include?('https://cocina.sul.stanford.edu/models/resources/page')
    end
  end

  def iiif3_manifest(**)
    @iiif3_manifest ||= Iiif3PresentationManifest.new(self, **)
  end

  def collection_items_link
    "#{Settings.searchworks.url}/catalog?f[collection][]=#{folio_instance_hrid || druid}"
  end

  def metrics
    metrics_service.get_metrics(druid)
  end

  concerning :Metadata do # rubocop:disable Metrics/BlockLength
    delegate :display_title, to: :cocina_display

    def description
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

    def item_type
      @item_type ||= ItemType.new(cocina['type'])
    end

    def folio_instance_hrid
      @folio_instance_hrid ||= cocina['identification']['catalogLinks']
                               .find { it['catalog'] == 'folio' }&.fetch('catalogRecordId')
    end

    def catalog_key
      @catalog_key ||= folio_instance_hrid&.delete_prefix('a')
    end

    def representative_thumbnail?
      thumbnail.present?
    end

    def representative_thumbnail
      "#{thumbnail_base_uri}/full/!400,400/0/default.jpg" if thumbnail
    end

    def thumbnail_base_uri
      thumbnail.stacks_iiif_base_uri
    end

    def thumbnail_service
      @thumbnail_service ||= ThumbnailService.new(structural_metadata)
    end

    # @return [StructuralMetadata::File] the thumbnail file
    def thumbnail
      thumbnail_service.thumb
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

  def cocina
    @cocina ||= JSON.parse(cocina_body)
  end

  def cocina_display
    @cocina_display ||= CocinaDisplay::CocinaRecord.new(cocina)
  end

  def mods_display_object
    @mods_display_object ||= ModsDisplay::Record.new(public_xml.mods.to_xml)
  end

  def metrics_service
    @metrics_service ||= MetricsService.new
  end

  def cocina_file(filename)
    structural_metadata.find_file_by_filename(filename)
  end
end
