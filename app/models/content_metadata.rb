class ContentMetadata
  attr_reader :document

  def initialize(document)
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

  ##
  # The content metadata has a druid for the resources which in practice
  # is the same for the overall item, but with virtual objects, the druid
  # for the resources changes to child items. So we include the druid at
  # the content metadata Resource-level to accommodate it.
  #
  # @return [String]
  def druid
    document.at_xpath('@objectId').to_s.gsub(/^druid:/, '') # required attribute
  end

  def resources
    return [] unless document

    @resources ||= document.xpath('resource').map do |resource|
      extract_resources(resource)
    end.flatten.compact.sort_by(&:sequence)
  end

  def deliverable_files
    resources.reject { |r| r.type == 'object' }
  end

  # rubocop:disable Metrics/AbcSize
  def extract_resources(resource)
    # extract resource-level attributes first
    resource_attributes = {
      id: resource.attribute('id').to_s,
      type: resource.attribute('type').to_s,
      label: resource.xpath('(label|attr[@name="label"])').first.try(:text),
      druid: druid,
      sequence: resource.attribute('sequence').value.to_i
    }

    resource.xpath('file|externalFile|resource').select { |node| Purl::Util.file_ready? node }.map do |node|
      case node.name
      when 'file'
        Resource.from_file_metadata(node, resource_attributes)
      when 'externalFile'
        Resource.from_external_file_metadata(node, resource_attributes)
      when 'resource'
        r = Resource.new(resource_attributes)
        r.sub_resources = extract_resources(node)
        r
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  class Resource
    include ActiveModel::Model
    attr_accessor :height, :width, :type, :mimetype, :size, :label, :url, :filename, :imagesvc, :sub_resource, :thumb, :druid, :id, :sequence

    ##
    # Extract attributes from `<file>...</file>` in content metadata
    #
    # @example
    #   <file id="2542A.jp2" mimetype="image/jp2" size="5789764">
    #     <imageData width="6475" height="4747"/>
    #   </file>
    def self.from_file_metadata(file, options = {})
      new(
        extract_common_metadata(file, options).merge(
          filename: file['id'],
          size: file['size'],
          url: file.at_xpath('location[@type="url"]/text()'),
          imagesvc: file.at_xpath('location[@type="imagesvc"]/text()')
        )
      )
    end

    ##
    # Extract attributes from `<externalFile>...</externalFile>` in content metadata
    #
    # @example
    #   <externalFile fileId="2542A.jp2" objectId="druid:cg767mn6478"
    #                 resourceId="cg767mn6478_1" mimetype="image/jp2">
    #     <imageData width="6475" height="4747"/>
    #   </externalFile>
    #
    def self.from_external_file_metadata(external_file, options = {})
      new(
        extract_common_metadata(external_file, options).merge(
          filename:   external_file['fileId'],
          druid:      external_file['objectId'].gsub(/^druid:/, ''),
          id:         external_file['resourceId']
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

    ##
    # Extract resource attributes from either `file` or `externalFile` elements in content metadata
    #
    # @param [Nokogiri::XML::Node] metadata -- the file or externalFile element
    # @return [Hash]
    def self.extract_common_metadata(metadata, options = {})
      options.merge(
        height:         metadata.at_xpath('imageData/@height').to_s.to_i,
        width:          metadata.at_xpath('imageData/@width').to_s.to_i,
        mimetype:       metadata['mimetype']
      )
    end
    private_class_method :extract_common_metadata
  end
end
