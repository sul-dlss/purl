# frozen_string_literal: true

class StructuralMetadata
  def initialize(json, druid)
    @json = json || {} # json is nil when the object is a collection
    @druid = druid
  end

  attr_accessor :json, :druid

  def virtual_object?
    virtual_object_members.present?
  end

  def virtual_object_members
    json.dig('hasMemberOrders', 0, 'members')
  end

  def virtual_object_thumbnail
    purl_version = PurlResource.find(virtual_object_members.first.delete_prefix('druid:')).version(:head)
    purl_version.structural_metadata.thumbnail
  end

  def file_sets
    @file_sets ||= Array(json['contains']).map { FileSet.new(it, druid) }
  end

  def local_files
    @local_files ||= file_sets.flat_map(&:files)
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
