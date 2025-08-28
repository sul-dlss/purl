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

    # TODO: actually change the test to use existing id, delete this method
    def cocina_id
      path = URI.parse(id).path.delete_prefix('/')
      "cocina-#{path.tr('/', '-')}"
    end

    def files
      @files ||= Array(json['structural']['contains']).map { File.new(druid: druid, json: it) }
    end

    def page_image?
      ['https://cocina.sul.stanford.edu/models/resources/image',
       'https://cocina.sul.stanford.edu/models/resources/page'].include?(type)
    end
  end
end
