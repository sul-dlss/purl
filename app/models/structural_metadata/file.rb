# frozen_string_literal: true

class StructuralMetadata
  class File
    def initialize(json)
      @json = json
    end

    attr_accessor :json

    def filename
      json['filename']
    end

    def access
      @access ||= FileAccess.new json['access']
    end
  end
end
