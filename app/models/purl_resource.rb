require 'dor/rights_auth'
require 'dor/util'

class PurlResource
  include ActiveModel::Model
  attr_accessor :id
  alias_method :druid, :id

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
    PurlResource.new(id: id)
  end

  def title
    Array.wrap(mods.title).join(' -- ') if mods?
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
    Dor::RightsAuth.parse(public_xml_document.at_xpath('/publicObject/rightsMetadata').to_s)
  end

  def type
    @type ||= public_xml_document.xpath('/publicObject/contentMetadata/@type').to_s
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
    el = public_xml_document.xpath('/publicObject/rightsMetadata/use/machine[@type="openDataCommons" or @type="creativeCommons"]').first

    "#{el.attribute('type')}-#{el.text}" if el && el.text.present?
  end

  def license_text
    public_xml_document.xpath('/publicObject/rightsMetadata/use/human[@type="openDataCommons" or @type="creativeCommons"]/text()').first
  end

  def copyright?
    copyright.present?
  end

  def copyright
    public_xml_document.xpath('/publicObject/rightsMetadata/copyright/human/text()').first.to_s
  end

  def use_and_reproduction?
    use_and_reproduction.present?
  end

  def use_and_reproduction
    public_xml_document.xpath('/publicObject/rightsMetadata/use/human[@type="useAndReproduction"]/text()').first.to_s
  end

  def catalog_key
    @catalog_key ||= begin
      key = public_xml_document.xpath('/publicObject/identityMetadata/otherId[@name="catkey"]/text()').to_s

      key if key.present?
    end
  end

  def persisted?
    true
  end
end
