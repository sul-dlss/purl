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

  def virtual_object_thumbnail
    return unless virtual_object_members&.any?

    purl_version = PurlResource.find(virtual_object_members&.first&.delete_prefix('druid:')).version(:head)
    purl_version.structural_metadata.thumbnail
  end

  # returns first image_file File
  def thumbnail
    file_sets.each { |fs| fs.files.each { |f| return f if f.image_file? } }
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

  def supplementing_resources
    local_files.select { |f| f.media_file? && f.mimetype == 'text/vtt' }
  end

  def primary
    return if local_files.blank?
    return local_files.first if local_files.length == 1

    return media_file if media_file.present?
    return image_file if image_file.present?

    pdf_file
  end

  def media_file
    local_files.find(&:media_file?)
  end

  def image_file
    local_files.find(&:image_file?)
  end

  def pdf_file
    @pdf_file ||= local_files.find { |file| file.type == 'document' || file.mimetype == 'application/pdf' }
  end

  def other_resources
    return [] unless local_files

    []

    # local_files - [primary, thumbnail_canvas].compact - supplementing_resources
    # local_files - [primary, thumbnail_canvas].compact - supplementing_resources
  end

  def thumbnail_canvas
    return unless media_file

    @thumbnail_canvas ||= image_file
  end
end
