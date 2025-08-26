# frozen_string_literal: true

class StructuralMetadata
  def initialize(json)
    @json = json || {} # json is nil when the object is a collection
  end

  attr_accessor :json

  def virtual_object?
    json.dig('hasMemberOrders', 0, 'members').present?
  end

  def resources
    @resources ||= Array(json['contains']).map { FileSet.new(it) }
  end

  def find_file_by_filename(filename)
    resources.flat_map(&:files).find { |file| file.filename == filename }
  end

  def viewing_direction
    json.dig('hasMemberOrders', 0, 'viewingDirection')
  end
end
