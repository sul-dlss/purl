# frozen_string_literal: true

class StructuralMetadata
  class FileSet
    def initialize(json)
      @json = json
    end

    attr_accessor :json

    def type
      json['type']
    end
  end
end
