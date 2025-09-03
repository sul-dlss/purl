# frozen_string_literal: true

# Responsible for finding a path to a thumbnail based on the structural metadata of an object
class ThumbnailService
  # @param [StructuralMetadata] structural cocina json
  def initialize(structural)
    @id = id
    @structural = structural
  end

  # @return [StructuralMetadata::File] the thumbnail file
  def thumb
    image = thumb_fs&.image_file
    return image if image
    return if structural.members.empty?

    begin
      self.class.new(PurlResource.find(structural.members.first.delete_prefix('druid:')).version(:head).structural_metadata).thumb
    rescue PurlResource::DruidNotValid
      Honeybadger.notify("Unable to find thumbnail for #{id}. Tried #{structural.members.first}")
    end
  end

  def thumb_fs
    structural.resources.each do |file_set|
      return file_set if file_set.image_file.present?
    end
    nil
  end

  private

  attr_reader :structural, :id
end
