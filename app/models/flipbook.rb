require 'purl/util'

class Flipbook
  delegate :druid, :title, to: :purl_resource
  attr_reader :purl_resource

  def initialize(purl_resource)
    @purl_resource = purl_resource
  end

  def to_json
    @json ||= {
      id: "#{catalog_key}",
      readGroup: read_group,
      objectId: "#{druid}",
      defaultViewMode: 2,
      bookTitle: title,
      readingOrder: reading_order,  # "rtl"
      pageStart: page_start,  # "left"
      bookURL: catalog_key? ? "http://searchworks.stanford.edu/view/#{catalog_key}" : '',
      pages: pages
    }
  end

  def deliverable_files
    purl_resource.public_xml_document.xpath('/publicObject/contentMetadata/resource').map do |resource|
      next if resource.attribute('type') == 'object'

      extract_resources(resource)
    end.flatten.compact
  end

  def extract_resources(resource)
    resource_attributes = {
      type: resource.attribute('type').to_s,
      label: resource.xpath('(label|attr[@name="label"])/text()').first.to_s
    }

    files = resource.xpath('file').select { |file| Purl::Util.is_file_ready? file }.map do |file|
      rights_attributes = { rights_stanford: purl_resource.rights.stanford_only_rights_for_file(file['id']), rights_world: purl_resource.rights.world_rights_for_file(file['id']) }
      Resource.from_content_metadata(file, resource_attributes.merge(rights_attributes))
    end

    resources = resource.xpath('resource').map do |nested_resource|
      r = Resource.new(resource_attributes)
      r.sub_resources = extract_resources(nested_resource)
      r
    end

    files + resources
  end

  class Resource
    include ActiveModel::Model
    attr_accessor :height, :width, :type, :mimetype, :label, :filename, :imagesvc, :sub_resource, :rights_stanford, :rights_world

    def self.from_content_metadata(file, options = {})
      new(
        options.merge(
          height: file.at_xpath('imageData/@height').to_s.to_i,
          width: file.at_xpath('imageData/@width').to_s.to_i,
          mimetype: file['mimetype'],
          filename: file['id'],
          imagesvc: file.xpath('location[@type="imagesvc"]/text()').first
        )
      )
    end

    def levels
      return unless width > 0 && height > 0
      ((Math.log([width, height].max) / Math.log(2)) - (Math.log(96) / Math.log(2))).ceil + 1
    end
  end

  def page_images
    deliverable_files.select do |file|
      file.mimetype == 'image/jp2' && (file.type == 'image' || file.type == 'page') && file.height > 0 && file.width > 0 && (file.rights_stanford || file.rights_world)
    end
  end

  def pages
    page_images.map do |file|
      {
        height: file.height,
        width: file.width,
        levels: file.levels,
        resourceType: file.type,
        label: file.label,
        stacksURL: Purl::Util.get_img_base_url(druid, Settings.stacks.url, file)
      }
    end
  end

  def catalog_key?
    catalog_key.present?
  end

  def catalog_key
    purl_resource.catalog_key
  end

  def read_group
    read = purl_resource.public_xml_document.xpath('/publicObject/rightsMetadata/access[@type="read"]/machine/*').first

    return unless read

    case read.name
    when 'group'
      read.text
    else
      read.name
    end
  end

  def reading_order
    purl_resource.public_xml_document.xpath('/publicObject/contentMetadata/bookData/@readingOrder').to_s
  end

  def page_start
    purl_resource.public_xml_document.xpath('/publicObject/contentMetadata/bookData/@pageStart').to_s
  end
end
