# frozen_string_literal: true

class DescriptionComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version
  delegate :form_display_data, :form_note_display_data, :language_display_data, :map_display_data, :event_note_display_data, :event_date_display_data,
           to: :cocina_display

  def label_id
    'section-description'
  end

  COMMA = ', '
  SEMICOLON = '; '

  # Ordered list of fields and delimiters to display
  def field_map
    @field_map ||= [
      [title_display_data, COMMA],
      [form_display_data, SEMICOLON],
      [form_note_display_data, COMMA],
      [publication_places, nil],
      [publisher, COMMA],
      [event_date_display_data, SEMICOLON],
      [event_note_display_data, COMMA],
      [language_display_data, SEMICOLON],
      [map_display_data, COMMA]
    ].select { |field, _| field.present? }
  end

  # All the titles, except the main title
  def title_display_data
    cocina_display.title_display_data.reject { it.label == 'Title' }
  end

  def publication_places
    CocinaDisplay::DisplayData.from_strings(cocina_display.publication_places, label: 'Place').presence
  end

  def publisher
    CocinaDisplay::DisplayData.from_strings(cocina_display.publisher_names, label: 'Publisher').presence
  end

  def render?
    field_map.present?
  end
end
