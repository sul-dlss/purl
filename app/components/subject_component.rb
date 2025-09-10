# frozen_string_literal: true

class SubjectComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version
  delegate :subject_display_data, :genre_display_data, to: :cocina_display

  def render?
    subject_display_data.present? || genre_display_data.present?
  end
end
