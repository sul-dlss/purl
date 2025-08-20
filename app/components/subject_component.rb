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

  def link_mods_subjects(subjects)
    linked_subjects = []
    subjects.each do |subject|
      linked_subjects << link_to_mods_subject(subject) if subject.present?
    end
    linked_subjects
  end

  # @param [ModsDisplay::Name::Person, String] subject
  def link_to_mods_subject(subject)
    subject_text = subject.respond_to?(:name) ? subject.name : subject
    if subject.respond_to?(:roles) && subject.roles.present?
      "#{subject_text} (#{subject.roles.join(', ')})"
    else
      subject_text
    end
  end
end
