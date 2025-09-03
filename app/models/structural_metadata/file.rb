# frozen_string_literal: true

class StructuralMetadata
  class File
    def initialize(druid:, json:)
      @druid = druid
      @json = json
    end

    attr_accessor :json, :druid

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

    def access
      @access ||= FileAccess.new json['access']
    end
  end
end
