# frozen_string_literal: true

class StructuralMetadata
  class File
    def initialize(druid:, json:)
      @druid = druid
      @json = json
      @fileset_id = fileset.cocina_id
      @fileset_label = fileset.label
    end

    attr_accessor :json, :druid, :fileset_id, :fileset_label

    def filename
      json['filename']
    end

    def mimetype
      json['hasMimeType']
    end

    def image?
      mimetype == 'image/jp2'
    end

    def stacks_iiif_base_uri
      "#{Settings.stacks.url}/image/iiif/#{druid}%2F#{ERB::Util.url_encode(::File.basename(filename, '.*'))}"
    end

    def height
      json.dig('presentation', 'height')
    end

    def width
      json.dig('presentation', 'width')
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
  end
end
