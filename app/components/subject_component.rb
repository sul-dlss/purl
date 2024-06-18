# frozen_string_literal: true

class SubjectComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  delegate :mods, to: :document

  def render?
    mods.subject.present? || mods.genre.present?
  end
end
