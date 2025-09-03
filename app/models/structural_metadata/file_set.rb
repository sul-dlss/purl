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

    def files
      @files ||= Array(json['structural']['contains']).map { File.new(druid: druid, json: it) }
    end
  end
end
