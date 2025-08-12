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

  def link_mods_subjects(subjects, &)
    link_buffer = []
    linked_subjects = []
    subjects.each do |subject|
      linked_subjects << link_to_mods_subject(subject, link_buffer, &) if subject.present?
    end
    linked_subjects
  end

  def link_to_mods_subject(subject, buffer = [])
    subject_text = subject.respond_to?(:name) ? subject.name : subject
    link = block_given? ? capture { yield(subject_text, buffer) } : subject_text
    buffer << subject_text.strip
    link << " (#{subject.roles.join(', ')})" if subject.respond_to?(:roles) && subject.roles.present?
    link
  end
end
