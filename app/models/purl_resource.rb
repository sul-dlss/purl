require 'find'

class PurlResource
  include ActiveModel::Model
  include ActiveSupport::Benchmarkable

  attr_accessor :id
  alias druid id

  class DruidNotValid < StandardError; end

  class ObjectNotReady < StandardError; end

  def self.all
    return [] unless Settings.document_cache_root
    return to_enum(:all) unless block_given?

    Find.find(Settings.document_cache_root) do |path|
      next unless path.ends_with?('public')

      # rubocop:disable Style/RegexpLiteral
      match = path.match(%r{#{Settings.purl_resource.public_xml % { druid: '(.*)', druid_tree: '(.*)' }}})
      # rubocop:enable Style/RegexpLiteral

      next unless match

      id = match[1].delete('/')

      yield PurlResource.find(id)
    end
  end

  def self.find(id)
    raise DruidNotValid, id unless Dor::Util.validate_druid(id)

    PurlResource.new(id:).tap do |obj|
      raise ObjectNotReady, id unless obj.ready?
    end
  end

  # rubocop:disable Naming/PredicateName
  def self.has_resource(options)
    options.each do |key, value|
      define_method "#{key}_resource" do
        response_cache[key] ||= cache_resource(key) do
          fetch_resource(key, value)
        end
      end

      define_method "#{key}_body" do
        send("#{key}_resource").body if send("#{key}_resource").success?
      end

      define_method "#{key}?" do
        send("#{key}_body").present?
      end
    end
  end
  # rubocop:enable Naming/PredicateName

  has_resource mods: Settings.purl_resource.mods
  has_resource public_xml: Settings.purl_resource.public_xml
  has_resource cocina: Settings.purl_resource.cocina

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

  # @return [String] the identifier of the collection this item is a member of
  def containing_collection
    @containing_collection ||= public_xml.relations('isMemberOfCollection').first
  end

  delegate :rights_metadata, to: :public_xml

  def content_metadata
    @content_metadata ||= ContentMetadata.new(public_xml.content_metadata)
  end

  # @returns [Bool] are there resources that can be shown?
  # This prevents adding links to the embed service, when that service can't generate a valid response.
  def embeddable?
    content_metadata.resources.present?
  end

  def rights
    @rights ||= RightsMetadata.new(rights_metadata)
  end

  def mods
    @mods ||= mods_display_object.mods_display_html&.presence
  end

  def iiif_manifest
    @iiif_manifest ||= IiifPresentationManifest.new(self)
  end

  def iiif_manifest?
    iiif_manifest.needed?
  end

  def iiif3_manifest
    @iiif3_manifest ||= Iiif3PresentationManifest.new(self)
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

    def license
      @license ||= License.new(code: license_code, text: license_text)
    end

    def license?
      license_code.present? || license_text.present?
    end

    def license_code
      type, code = rights.machine_readable_license

      "#{type}-#{code}" if type.present? && code.present?
    end

    def license_text
      rights.license_statement
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

    delegate :catalog_key, to: :public_xml

    delegate :released_to?, to: :public_xml

    def representative_thumbnail?
      representative_thumbnail.present?
    end

    def representative_thumbnail
      "#{iiif_manifest.thumbnail_base_uri}/full/!400,400/0/default.jpg" if iiif_manifest.thumbnail_base_uri.present?
    end

    # @return [String,nil] DOI (with https://doi.org/ prefix) if present
    def doi
      @doi ||= mods_document.root&.at_xpath('mods:identifier[@type="doi"]', mods: 'http://www.loc.gov/mods/v3')&.text
    end

    # @return [String,nil] DOI (without https://doi.org/ prefix) if present
    def doi_id
      doi&.delete_prefix('https://doi.org/')
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
      { druid: id, druid_tree: }
    end

    def persisted?
      true
    end

    private

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

    def response_cache
      @response_cache ||= {}
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
    @mods_display_object ||= ModsDisplay::Record.new(mods_body)
  end

  def mods_document
    @mods_document ||= Nokogiri::XML(mods_body)
  end

  def logger
    Rails.logger
  end
end
