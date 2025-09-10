# frozen_string_literal: true

class DescriptionComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :mods, :cocina_display, to: :version
  delegate :form, :publisher, :dateCreated, :dateCaptured, :dateValid, :dateModified, :dateOther, :copyrightDate, :dateIssued,
           :issuance, :frequency, :edition, :description, to: :mods
  delegate :language_display_data, :map_display_data, to: :cocina_display

  def label_id
    'section-description'
  end

  COMMA = ', '
  SEMICOLON = '; '

  # Ordered list of fields and delimiters to display
  def field_map # rubocop:disable Metrics/AbcSize
    @field_map ||= [
      [alternative_title, nil],
      [other_title, COMMA],
      [resource_types, COMMA],
      [form, SEMICOLON],
      [extent, COMMA],
      [publication_places, nil],
      [publisher, COMMA],
      [dateCreated, SEMICOLON],
      [dateCaptured, SEMICOLON],
      [dateValid, SEMICOLON],
      [dateModified, SEMICOLON],
      [dateOther, SEMICOLON],
      [copyrightDate, SEMICOLON],
      [dateIssued, SEMICOLON],
      [issuance, COMMA],
      [frequency, COMMA],
      [edition, COMMA],
      [language_display_data, SEMICOLON],
      [description, COMMA],
      [map_display_data, COMMA]
    ].select { |field, _| field.present? }
  end

  def alternative_title
    mods.mods_field(:title).fields.select { |x| x.label =~ /^Alternative Title/i }
  end

  def other_title
    mods.mods_field(:title).fields.reject { |x| x.label =~ /^(Alternative )?Title/i }
  end

  def resource_types
    objects = cocina_display.resource_types
    [CocinaDisplay::DisplayData.new(label: 'Resource Type', objects:)] if objects.present?
  end

  def extent
    objects = cocina_display.extents
    [CocinaDisplay::DisplayData.new(label: 'Extent', objects:)] if objects.present?
  end

  def publication_places
    objects = cocina_display.publication_places
    [CocinaDisplay::DisplayData.new(label: 'Place', objects:)] if objects.present?
  end

  def render?
    field_map.present?
  end
end
