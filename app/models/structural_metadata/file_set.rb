# frozen_string_literal: true

class StructuralMetadata
  class FileSet
    def initialize(json, druid)
      @json = json
      @druid = druid
    end

    attr_accessor :json, :druid

    def type
      json['type']
    end

    def id
      json['externalIdentifier']
    end

    def label
      json['label']
    end

    # TODO: actually change the test to use existing id, delete this method
    def cocina_id
      # TODO: use sub instead
      # resource['id'].sub('https://cocina.sul.stanford.edu/fileSet/', 'cocina-fileSet-')
      path = URI.parse(id).path.delete_prefix('/')
      "cocina-#{path.tr('/', '-')}"
    end

    def files
      @files ||= Array(json['structural']['contains']).map { File.new(it, druid, self) }
    end

    def page_image?
      ['https://cocina.sul.stanford.edu/models/resources/image',
       'https://cocina.sul.stanford.edu/models/resources/page'].include?(type)
    end

    def primary
      return if files.blank?
      return files.first if files.length == 1

      return media_file if media_file.present?
      return image_file if image_file.present?

      pdf_file
    end

    def audio?
      type == 'https://cocina.sul.stanford.edu/models/resources/audio'
    end

    def media_file
      return nil unless ['https://cocina.sul.stanford.edu/models/resources/video',
       'https://cocina.sul.stanford.edu/models/resources/audio'].include?(type)
      
       files.find{ it.mimetype.start_with?('video/', 'audio/') }
    end

    def image_file
      files.find(&:image_file?)
    end

    def pdf_file
       return nil unless ['https://cocina.sul.stanford.edu/models/resources/document'].include?(type)
      
       files.find{ it.mimetype.start_with?('application/pdf') }
    end

    def other_resources
      return [] unless files
  
      files - [primary, thumbnail_canvas].compact - supplementing_resources
    end

    def supplementing_resources
      return [] if media_file.blank?

      files.select { |file| file.mimetype == 'text/vtt' }
    end

    def thumbnail_canvas
      return unless media_file

      @thumbnail_canvas ||= image_file
    end

  end
end
