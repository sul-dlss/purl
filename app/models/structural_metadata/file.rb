# frozen_string_literal: true

class StructuralMetadata
  class File
    def initialize(druid:, json:, fileset:)
      @druid = druid
      @json = json
      @fileset = fileset
      @fileset_label = fileset.label
    end

    attr_accessor :json, :druid, :fileset, :fileset_label

    def fileset_id
      fileset.cocina_id
    end

    def filename
      json['filename']
    end

    def mimetype
      json['hasMimeType']
    end

    def stacks_iiif_base_uri
      "#{Settings.stacks.url}/image/iiif/#{druid}%2F#{ERB::Util.url_encode(::File.basename(filename, '.*'))}"
    end

    def image_height
      json.dig('presentation', 'height')
    end

    def image_width
      json.dig('presentation', 'width')
    end

    def height
      return image_height if viewable?

      thumbnail_height
    end

    def width
      return image_width if viewable?

      thumbnail_width
    end

    # thumbnail width/height sets long edge to 400px
    # then calculates the correct dimensions for the short edge to preserve aspect ratio
    def thumbnail_height
      if height >= width
        400
      else
        ((400.0 * height) / width).round
      end
    end

    def thumbnail_width
      if height >= width
        ((400.0 * width) / height).round
      else
        400
      end
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

    def viewable?
      %w[world stanford location-based].include?(access.view)
    end

    def role
      json['use']
    end

    def image_file?
      mimetype == 'image/jp2' && height.positive? && width.positive?
    end
  end
end
