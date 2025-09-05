# frozen_string_literal: true

class AbstractContentsComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version

  def items
    @items ||= cocina_display.abstract_display_data + cocina_display.table_of_contents_display_data
  end

  def render?
    items.present?
  end
end
