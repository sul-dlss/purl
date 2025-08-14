# frozen_string_literal: true

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

  def book_data
    document&.at_xpath('bookData')
  end

  ##
  # The content metadata has a druid for the resources which in practice
  # is the same for the overall item, but with virtual objects, the druid
  # for the resources changes to child items. So we include the druid at
  # the content metadata Resource-level to accommodate it.
  #
  # @return [String]
  def druid
    document.at_xpath('@objectId').to_s.delete_prefix('druid:') # required attribute
  end

  def resources
    return [] unless document

    @resources ||= ResourceXmlDeserializer.build_resources(document, druid)
  end

  def grouped_resources
    @grouped_resources ||= resources.group_by(&:sequence).sort.map { |grouped_resource| GroupedResource.from_grouping(*grouped_resource) }
  end

  ##
  # A collection of SDR ContentMetadata Resource Files grouped by resource sequence
  class GroupedResource
    attr_reader :index, :files, :id

    def initialize(index:, files:, id:)
      @index = index
      @files = files
      @id = id
    end

    def self.from_grouping(index, files)
      new(index:, files:, id: files[0].id)
    end

    def primary
      return if files.blank?
      return files.first if files.length == 1

      return media_file if media_file.present?
      return image_file if image_file.present?

      pdf_file
    end

    def supplementing_resources
      return [] if media_file.blank?

      files.select { |file| file.mimetype == 'text/vtt' }
    end

    def thumbnail_canvas
      return unless media_file

      @thumbnail_canvas ||= image_file
    end

    def other_resources
      return [] unless files

      files - [primary, thumbnail_canvas].compact - supplementing_resources
    end

    def pdf_file
      @pdf_file ||= files.find { |file| file.type == 'document' || file.mimetype == 'application/pdf' }
    end

    def media_file
      @media_file ||= files.find do |file|
        %w[video audio].include?(file.type) && ((file.mimetype.start_with? 'video/') || (file.mimetype.start_with? 'audio/'))
      end
    end

    def image_file
      @image_file ||= files.find { |file| file.mimetype == 'image/jp2' }
    end
  end
end
