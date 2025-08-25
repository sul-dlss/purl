# frozen_string_literal: true

class SubjectComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  delegate :mods, to: :document
  delegate :genre, :subject, to: :mods

  def render?
    subject.present? || genre.present?
  end

  # @param [Array<ModsDisplay::Name::Person, String>] subjects
  def expand_subject_name(subjects)
    subjects.map do |subject|
      subject.respond_to?(:name) ? subject.name : subject
    end
  end
end
