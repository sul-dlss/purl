# frozen_string_literal: true

class StructuralMetadata
  def initialize(druid:, json:)
    @druid = druid
    @json = json || {} # json is nil when the object is a collection
    @druid = druid
  end

  attr_accessor :json, :druid

  def virtual_object?
    members.present?
  end

  def members
    json.dig('hasMemberOrders', 0, 'members') || []
  end

  def resources
    @resources ||= Array(json['contains']).map { FileSet.new(druid:, json: it) }
  end

  def find_file_by_filename(filename)
    file_sets.flat_map(&:files).find { |file| file.filename == filename }
  end

  def viewing_direction
    json.dig('hasMemberOrders', 0, 'viewingDirection')
  end

  def containing_collections
    Array(json['isMemberOf']).map { it.delete_prefix('druid:') }
  end

  # returns first image_file File
  def thumbnail
    file_sets.each { |fs| fs.files.each { |f| return f if f.image_file? } }
  end
end
