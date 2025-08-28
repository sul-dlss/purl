# frozen_string_literal: true

class StructuralMetadata
  class File
    def initialize(json, druid, fileset)
      @json = json
      @druid = druid
      @fileset_id = fileset.cocina_id
      @fileset_label = fileset.label
    end

    attr_accessor :json, :druid, :fileset_id, :fileset_label

    def filename
      json['filename']
    end

    def id
      json['externalIdentifier']
    end

    def type
      json['type']
    end

    def label
      json['label']
    end

    def size
      json['size']
    end

    def access
      @access ||= FileAccess.new json['access']
    end

    def role
      json['use']
    end

    def mimetype
      json['hasMimeType']
    end

    def height
      json['presentation']['height']
    end

    def width
      json['presentation']['width']
    end

    def image_file?
      mimetype == 'image/jp2' && height.positive? && width.positive?
    end

    def media_file?
      ['https://cocina.sul.stanford.edu/models/resources/video',
       'https://cocina.sul.stanford.edu/models/resources/audio'].include?(type) &&
        mimetype.start_with?('video/', 'audio/')
    end
  end
end
