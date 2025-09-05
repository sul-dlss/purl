# frozen_string_literal: true

class CitationComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version

  def items
    @items ||= cocina_display.preferred_citation_display_data
  end

  def render?
    items.present?
  end
end
