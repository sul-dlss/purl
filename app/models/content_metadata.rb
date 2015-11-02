class ContentMetadata
  attr_reader :druid, :document

  def initialize(druid, document)
    @druid = druid
    @document = document
  end

  def type
    document.attribute('type').to_s if document
  end

  def reading_order
    book_data.attribute('readingOrder').to_s if book_data
  end

  def page_start
    book_data.attribute('pageStart').to_s if book_data
  end

  def book_data
    document.at_xpath('bookData') if document
  end

  def resources
    return [] unless document

    @resources ||= document.xpath('resource').map do |resource|
      extract_resources(resource)
    end.flatten.compact
  end

  def deliverable_files
    resources.reject { |r| r.type == 'object' }
  end

  def downloadable_files
    resources.select { |r| r.type == 'object' }
  end

  def extract_resources(resource)
    resource_attributes = {
      druid: druid,
      type: resource.attribute('type').to_s,
      label: resource.xpath('(label|attr[@name="label"])/text()').first.to_s
    }

    files = resource.xpath('file').map do |file|
      Resource.from_content_metadata(file, resource_attributes)
    end

    resources = resource.xpath('resource').map do |nested_resource|
      r = Resource.new(resource_attributes)
      r.sub_resources = extract_resources(nested_resource)
      r
    end

    (files + resources).select(&:ready?)
  end

  class Resource
    include ActiveModel::Model

    attr_accessor :druid
    attr_accessor :height, :width, :type, :mimetype, :size, :label, :url, :filename, :imagesvc, :sub_resource, :thumb
    attr_accessor :deliver, :publish

    def self.from_content_metadata(file, options = {})
      new(
        options.merge(
          height: file.at_xpath('imageData/@height').to_s.to_i,
          width: file.at_xpath('imageData/@width').to_s.to_i,
          mimetype: file['mimetype'],
          filename: file['id'],
          size: file['size'],
          url: file.at_xpath('location[@type="url"]/text()'),
          imagesvc: file.at_xpath('location[@type="imagesvc"]/text()'),
          deliver: file['deliver'],
          publish: file['publish']
        )
      )
    end

    def thumbnail?
      !!thumb
    end

    def levels
      return unless width > 0 && height > 0
      ((Math.log([width, height].max) / Math.log(2)) - (Math.log(96) / Math.log(2))).ceil + 1
    end

    def ready?
      deliver != 'no' || publish != 'no'
    end

    # get file label (if available) or jp2 id
    def display_label
      label = label.to_s if label.present?
      label ||= filename.gsub(/\.jp2$/i, '')

      label
    end

    def delivery_url
      url || stacks_url
    end

    private

    def stacks_url
      Settings.stacks.url + '/file/druid:' + druid + '/' + filename
    end
  end
end
