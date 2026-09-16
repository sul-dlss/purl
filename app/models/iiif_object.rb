# frozen_string_literal: true

# Value object containing the data needed to generate IIIF manifests.
class IiifObject
  include ActiveModel::Model

  delegate :collection?, :book?, to: :item_type

  def self.from_purl_version(purl_version)
    structural_metadata = purl_version.structural_metadata
    new(**purl_version_attributes(purl_version), **structural_attributes(structural_metadata))
  end

  def self.purl_version_attributes(purl_version)
    {
      druid: purl_version.druid,
      display_title: purl_version.display_title,
      updated_at: purl_version.updated_at,
      cocina_display: purl_version.cocina_display,
      item_type: purl_version.item_type,
      copyright: purl_version.cocina_display.copyright,
      collection_title: collection_title(purl_version),
      object_type: purl_version.cocina['type'],
      thumbnail: purl_version.thumbnail,
      thumbnail_file_set: purl_version.thumbnail_service.thumb_fs,
      label: purl_version.cocina['label'],
      version_id: purl_version.version_id,
      head: purl_version.head?
    }
  end
  private_class_method :purl_version_attributes

  def self.structural_attributes(structural_metadata)
    {
      file_sets: structural_metadata.file_sets,
      members: structural_metadata.members,
      viewing_direction: structural_metadata.viewing_direction
    }
  end
  private_class_method :structural_attributes

  def self.collection_title(purl_version)
    collection = purl_version.containing_purl_collections&.first
    collection&.last&.display_title
  end
  private_class_method :collection_title

  def initialize(file_sets: [], members: [], object_type: nil, thumbnail_file_set: nil, **attributes)
    @object_type = object_type
    super(attributes)
    self.members = members
    self.file_sets = file_sets
    self.thumbnail_file_set = thumbnail_file_set
  end

  attr_accessor :druid, :display_title, :updated_at, :cocina_display, :item_type, :copyright, :collection_title,
                :members, :viewing_direction, :thumbnail, :label, :version_id
  attr_reader :file_sets, :local_files, :thumbnail_file_set
  attr_writer :head

  def file_sets=(file_sets)
    @file_sets = file_sets.map { |file_set| IiifResourceSet.new(file_set, object_type:) }
    @local_files = file_sets.flat_map(&:files)
  end

  def thumbnail_file_set=(file_set)
    @thumbnail_file_set = file_set && IiifResourceSet.new(file_set, object_type:)
  end

  def head?
    @head
  end

  def representative_thumbnail
    "#{thumbnail_base_uri}/full/!400,400/0/default.jpg" if thumbnail
  end

  def thumbnail_base_uri
    thumbnail&.stacks_iiif_base_uri
  end

  def license
    cocina_display&.license
  end

  def iiif2_metadata
    iiif2_metadata_writer.write.flatten
  end

  def iiif2_summary
    iiif2_metadata_writer.summary
  end

  def iiif3_metadata
    iiif3_metadata_writer.write
  end

  def iiif3_summary
    iiif3_metadata_writer.summary
  end

  def nav_place
    @nav_place ||= begin
      nav_place = IIIF::V3::Presentation::NavPlace.new(coordinate_texts: cocina_display.coordinates, base_uri: nil)
      nav_place.valid? ? nav_place.build : nil
    end
  end

  private

  attr_reader :object_type

  def iiif2_metadata_writer
    @iiif2_metadata_writer ||= Iiif2MetadataWriter.new(cocina_display:, published_date: updated_at, collection_title:)
  end

  def iiif3_metadata_writer
    @iiif3_metadata_writer ||= Iiif3MetadataWriter.new(cocina_display:, published_date: updated_at, collection_title:)
  end
end
