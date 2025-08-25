# frozen_string_literal: true

class StructuralMetadata
  def initialize(json)
    @json = json || {} # json is nil when the object is a collection
  end

  attr_accessor :json

  def virtual_object?
    json['hasMemberOrders'].present?
  end

  def resources
    @resources ||= Array(json['contains']).map { FileSet.new(it) }
  end
end
