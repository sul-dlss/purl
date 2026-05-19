# frozen_string_literal: true

class AbstractContentsComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version

  def render?
    (cocina_display.abstract_display_data + cocina_display.table_of_contents_display_data).present?
  end
end
