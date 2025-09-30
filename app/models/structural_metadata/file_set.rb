# frozen_string_literal: true

class StructuralMetadata
  class FileSet
    def initialize(druid:, json:)
      @druid = druid
      @json = json
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

    # Most common externalIdentifier formatation is: https://cocina.sul.stanford.edu/fileSet/bc854fy5899-bc854fy5899_112 (uri druid-filesetid)
    # However non-uri fileset_id exists like hx163dc5225_31, rx923hn2102_35, fj935vg7746_1
    # There are also some malformed uuids, there is a ticket https://github.com/sul-dlss/purl/issues/1454 for this issue
    # This cleans the externalIdentifier so it is the same
    def cocina_id
      fileset_id = id.split('/')[-1]
      return "cocina-fileSet-#{druid}-#{fileset_id}" unless fileset_id.start_with?("#{druid}-")

      "cocina-fileSet-#{fileset_id}"
    end

    def files
      @files ||= Array(json['structural']['contains']).map { File.new(druid: druid, json: it, fileset: self) }
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

    def media?
      audio? || type == 'https://cocina.sul.stanford.edu/models/resources/video'
    end

    def image?
      type == 'https://cocina.sul.stanford.edu/models/resources/image'
    end

    def media_file
      return nil unless media?

      files.find { it.mimetype.start_with?('video/', 'audio/') }
    end

    def image_file
      files.find(&:image_file?)
    end

    def pdf_file
      return nil unless ['https://cocina.sul.stanford.edu/models/resources/document'].include?(type)

      files.find { it.mimetype.start_with?('application/pdf') }
    end

    def other_resources
      return [] unless files

      files - [primary, media_thumbnail].compact - supplementing_resources
    end

    def supplementing_resources
      return [] if media_file.blank?

      files.select { |file| file.mimetype == 'text/vtt' }
    end

    def media_thumbnail
      return unless media_file

      @media_thumbnail ||= image_file
    end
  end
end
