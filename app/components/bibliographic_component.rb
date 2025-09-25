# frozen_string_literal: true

class BibliographicComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version
  delegate :general_note_display_data, :identifier_display_data, :access_display_data, :related_resource_display_data, to: :cocina_display
  delegate :doi, to: :version

  def render?
    general_note_display_data.present? ||
      related_resource_display_data.present? ||
      identifier_display_data.present? ||
      doi.present? ||
      access_display_data.present?
  end

  def doi_display_data
    [CocinaDisplay::DisplayData.new(label: 'DOI', objects: [doi])] if doi.present?
  end
end
