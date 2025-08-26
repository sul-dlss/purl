# frozen_string_literal: true

class StructuralMetadata
  class FileAccess
    def initialize(json)
      @json = json
    end

    attr_accessor :json

    def download
      json['download']
    end

    def view
      json['view']
    end
  end
end
