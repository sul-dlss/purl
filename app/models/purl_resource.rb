require 'dor/util'

class PurlResource
  include ActiveModel::Model
  attr_accessor :id
  alias_method :druid, :id

  class DruidNotValid < StandardError; end
  class ObjectNotReady < StandardError; end

  # rubocop:disable Metrics/MethodLength, Style/PredicateName
  def self.has_resource(options)
    options.each do |key, value|
      define_method "#{key}_resource" do
        response_cache[key] ||= cache_resource(key) do
          fetch_resource(value)
        end
      end

      define_method "#{key}_body" do
        send("#{key}_resource").body if send("#{key}?")
      end

      define_method "#{key}?" do
        send("#{key}_resource").success?
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Style/PredicateName

  def response_cache
    @response_cache ||= {}
  end

  has_resource mods: Settings.purl_resource.mods
  has_resource public_xml: Settings.purl_resource.public_xml
  has_resource iiif_manifest: Settings.purl_resource.iiif_manifest

  def self.find(id)
    fail DruidNotValid, id unless Dor::Util.validate_druid(id)

    PurlResource.new(id: id).tap do |obj|
      fail ObjectNotReady, id unless obj.ready?
    end
  end

  def title
    Array.wrap(mods.title).join(' -- ') if mods?
  end

  def description
    @description ||= begin
      abstract = mods.abstract.detect { |a| a.respond_to? :values }
      if abstract
        abstract.values.join
      else
        ''
      end
    end
  end

  def ready?
    public_xml?
  end

  def mods_display_object
    @mods_display_object ||= ModsDisplayObject.new(mods_body)
  end

  def mods
    @mods ||= mods_display_object.render_mods_display(mods_display_object)
  end

  def public_xml_document
    @public_xml_document ||= Nokogiri::XML(public_xml_body)
  end

  def mods_document
    @mods_document ||= Nokogiri::XML(mods_body)
  end

  def rights
    @rights ||= RightsMetadata.new(rights_metadata)
  end

  delegate :rights_metadata, to: :public_xml

  def content_metadata
    @content_metadata ||= ContentMetadata.new(public_xml.content_metadata)
  end

  def public_xml
    @public_xml ||= PublicXml.new(public_xml_document)
  end

  def type
    @type ||= content_metadata.type
  end

  def flipbook?
    type =~ /Book|Manuscript/i
  end

  def flipbook
    @flipbook ||= Flipbook.new(self)
  end

  def attributes
    { druid: id, druid_tree: druid_tree }
  end

  def druid_tree
    Dor::Util.create_pair_tree(druid) || druid
  end

  def cache_key
    "purl_resource/druid:#{id}"
  end

  def cache_resource(key, &block)
    Rails.cache.fetch("#{cache_key}/#{key}", expires_in: Settings.resource_cache.lifetime, &block)
  end

  def fetch_resource(value)
    url_or_path = value % attributes

    case url_or_path
    when /^http/
      Hurley.get(url_or_path)
    else
      DocumentCacheResource.new(url_or_path)
    end
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

  def catalog_key
    @catalog_key ||= begin
      key = public_xml_document.xpath('/publicObject/identityMetadata/otherId[@name="catkey"]/text()').to_s

      key if key.present?
    end
  end

  def released_to?(key)
    release = public_xml_document.xpath("/publicObject/releaseData/release[@to='#{key}']/text()").to_s

    release == 'true'
  end

  def persisted?
    true
  end

  def updated_at
    if public_xml_resource.respond_to? :updated_at
      public_xml_resource.updated_at
    elsif public_xml_resource.respond_to?(:header) && public_xml_resource.header[:last_modified].present?
      public_xml_resource.header[:last_modified]
    else
      Time.zone.now
    end
  end

  def iiif_manifest
    return {} unless iiif_manifest?
    @iiif_manifest ||= JSON.parse(iiif_manifest_body)
  end

  def representative_thumbnail?
    representative_thumbnail.present?
  end

  def representative_thumbnail
    iiif_manifest.fetch('thumbnail', {})['@id']
  end
end
