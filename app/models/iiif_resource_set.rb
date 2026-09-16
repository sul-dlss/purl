# frozen_string_literal: true

# Adds IIIF-specific resource selection behavior to a StructuralMetadata::FileSet.
class IiifResourceSet
  def initialize(file_set, object_type:)
    @file_set = file_set
    @object_type = object_type
  end

  attr_reader :file_set, :object_type

  delegate_missing_to :file_set

  def page_image?
    ['https://cocina.sul.stanford.edu/models/resources/image',
     'https://cocina.sul.stanford.edu/models/resources/page'].include?(type)
  end

  def audio?
    type == 'https://cocina.sul.stanford.edu/models/resources/audio'
  end

  def media?
    audio? || type == 'https://cocina.sul.stanford.edu/models/resources/video'
  end

  def image?
    type == 'https://cocina.sul.stanford.edu/models/resources/image'
  end

  def media_file
    return unless media?

    files.find { it.mimetype.start_with?('video/', 'audio/') }
  end

  def image_file
    files.find(&:image_file?)
  end

  def pdf_file
    return unless type == 'https://cocina.sul.stanford.edu/models/resources/document'

    files.find { it.mimetype.start_with?('application/pdf') }
  end

  def primary
    return if files.blank? || geo?
    return files.first if files.length == 1

    media_file || image_file || pdf_file || files.first
  end

  def other_resources
    return [] unless files

    files - [primary, media_thumbnail].compact - supplementing_resources
  end

  def supplementing_resources
    return [] unless media_file

    files.select { |file| file.mimetype == 'text/vtt' }
  end

  def media_thumbnail
    return unless media_file

    @media_thumbnail ||= thumbnail_file
  end

  private

  def geo?
    object_type == 'https://cocina.sul.stanford.edu/models/geo'
  end
end
