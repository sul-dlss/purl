# frozen_string_literal: true

class DescriptionComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version

  def label_id
    'section-description'
  end

  COMMA = ', '
  SEMICOLON = '; '

  # Ordered list of fields and delimiters to display
  def field_map
    @field_map ||= [
      [additional_title_display_data, COMMA],
      [cocina_display.form_display_data, SEMICOLON],
      [cocina_display.form_note_display_data, COMMA],
      [cocina_display.event_display_data, SEMICOLON],
      [cocina_display.event_note_display_data, COMMA],
      [cocina_display.language_display_data, SEMICOLON],
      [cocina_display.map_display_data, COMMA]
    ].select { |field, _| field.present? }
  end

  # The primary title itself is rendered in the page header, but its parallel
  # values belong in the description alongside secondary titles.
  def additional_title_display_data
    primary_title_siblings = Array(cocina_display.primary_title&.main_value&.siblings)
    CocinaDisplay::DisplayData.from_objects(primary_title_siblings) +
      cocina_display.title_display_data(exclude_primary: true)
  end

  def render?
    field_map.present?
  end
end
