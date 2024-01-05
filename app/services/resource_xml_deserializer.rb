class ResourceXmlDeserializer
  def self.build_resources(document, druid)
    document.xpath('resource').map do |resource|
      extract_resources(resource, druid)
    end.flatten.compact.sort_by(&:sequence)
  end

  def self.extract_resources(resource_node, druid)
    # extract resource-level attributes first
    resource_attributes = {
      id: resource_node.attribute('id').to_s,
      type: resource_node.attribute('type').to_s,
      label: resource_node.xpath('(label|attr[@name="label"])').first.try(:text),
      druid:
    }

    resource_attributes[:sequence] = if resource_node.attribute('sequence')
                                       resource_node.attribute('sequence').value.to_i
                                     else
                                       Float::INFINITY
                                     end

    resource_node.xpath('file|externalFile|resource').select { |node| Purl::Util.file_ready? node }.map do |node|
      case node.name
      when 'file'
        Resource.from_file_metadata(node, resource_attributes)
      when 'externalFile'
        Resource.from_external_file_metadata(node, resource_attributes)
      end
    end
  end

  class Resource
    ##
    # Extract attributes from `<file>...</file>` in content metadata
    #
    # @example
    #   <file id="2542A.jp2" mimetype="image/jp2" size="5789764">
    #     <imageData width="6475" height="4747"/>
    #   </file>
    def self.from_file_metadata(file, options = {})
      ResourceFile.new(
        extract_common_metadata(file, options).merge(
          filename: file['id'],
          size: file['size'],
          role: file['role'],
          url: file.at_xpath('location[@type="url"]/text()'),
          imagesvc: file.at_xpath('location[@type="imagesvc"]/text()')
        )
      )
    end

    ##
    # Extract attributes from `<externalFile>...</externalFile>` in content metadata
    #  or structural.hasMemberOrders[0].members in cocina
    #
    # @example
    #   <externalFile fileId="2542A.jp2" objectId="druid:cg767mn6478"
    #                 resourceId="cg767mn6478_1" mimetype="image/jp2">
    #     <imageData width="6475" height="4747"/>
    #   </externalFile>
    #
    def self.from_external_file_metadata(external_file, options = {})
      ResourceFile.new(
        extract_common_metadata(external_file, options).merge(
          filename: external_file['fileId'],
          druid: external_file['objectId'].delete_prefix('druid:'),
          id: external_file['resourceId']
        )
      )
    end

    def levels
      return unless width.positive? && height.positive?

      ((Math.log([width, height].max) / Math.log(2)) - (Math.log(96) / Math.log(2))).ceil + 1
    end

    ##
    # Extract resource attributes from either `file` or `externalFile` elements in content metadata
    #
    # @param [Nokogiri::XML::Node] metadata -- the file or externalFile element
    # @return [Hash]
    def self.extract_common_metadata(metadata, options = {})
      options.merge(
        height: metadata.at_xpath('imageData/@height').to_s.to_i,
        width: metadata.at_xpath('imageData/@width').to_s.to_i,
        mimetype: metadata['mimetype']
      )
    end
    private_class_method :extract_common_metadata
  end
end
