require 'dor/util'

class PurlResource
  include ActiveModel::Model
  include ActiveSupport::Benchmarkable

  attr_accessor :id
  alias_method :druid, :id

  class DruidNotValid < StandardError; end
  class ObjectNotReady < StandardError; end

  def self.find(id)
    fail DruidNotValid, id unless Dor::Util.validate_druid(id)

    PurlResource.new(id: id).tap do |obj|
      fail ObjectNotReady, id unless obj.ready?
    end
  end

  # rubocop:disable Style/PredicateName
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
  # rubocop:enable Style/PredicateName

  has_resource mods: Settings.purl_resource.mods
  has_resource public_xml: Settings.purl_resource.public_xml

  def ready?
    public_xml?
  end

  def public_xml_document
    @public_xml_document ||= Nokogiri::XML(public_xml_body)
  end

  def public_xml
    @public_xml ||= PublicXml.new(public_xml_document)
  end

  delegate :rights_metadata, to: :public_xml

  def content_metadata
    @content_metadata ||= ContentMetadata.new(public_xml.content_metadata)
  end

  def rights
    @rights ||= RightsMetadata.new(rights_metadata)
  end

  def mods
    @mods ||= begin
      m = mods_display_object.render_mods_display(mods_display_object)
      m unless m.blank?
    end
  end

  def iiif_manifest
    @iiif_manifest ||= IiifPresentationManifest.new(self)
  end

  def iiif_manifest?
    iiif_manifest.needed?
  end

  def flipbook
    @flipbook ||= Flipbook.new(self)
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
      @description ||= begin
        abstract = mods.abstract.detect { |a| a.respond_to? :values }
        if abstract
          abstract.values.join.strip
        else
          ''
        end
      end if mods?
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

    def flipbook?
      type =~ /Book|Manuscript/i
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
      { druid: id, druid_tree: druid_tree }
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
          Hurley.get(url_or_path).tap do |response|
            # strip ssl options to support cache serialization
            response.request.ssl_options = Hurley::SslOptions.new
          end
        else
          DocumentCacheResource.new(url_or_path)
        end
      end
    end
  end

  private

  def mods_display_object
    @mods_display_object ||= ModsDisplayObject.new(mods_body)
  end

  def mods_document
    @mods_document ||= Nokogiri::XML(mods_body)
  end

  def logger
    Rails.logger
  end
end
