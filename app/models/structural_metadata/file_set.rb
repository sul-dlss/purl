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
      path = URI.parse(id).path.delete_prefix('/')
      "cocina-#{path.tr('/', '-')}"
    end

    def files
      @files ||= Array(json['structural']['contains']).map { File.new(it, druid, self) }
    end
  end
end
