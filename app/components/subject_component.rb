# frozen_string_literal: true

class SubjectComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version
  delegate :subject_display_data, :genre_display_data, to: :cocina_display

  # CocinaDisplay chooses one main value for a parallel subject. On the PURL,
  # display every parallel value so vernacular and transliterated subjects are
  # available to visitors.
  def expanded_subject_display_data
    expand_parallel_values(subject_display_data)
  end

  def expanded_genre_display_data
    expand_parallel_values(genre_display_data)
  end

  def render?
    expanded_subject_display_data.present? || expanded_genre_display_data.present?
  end

  private

  def expand_parallel_values(display_data)
    display_data.map do |field|
      objects = field.objects.flat_map do |object|
        object.respond_to?(:parallel_values) ? object.parallel_values : object
      end
      CocinaDisplay::DisplayData.new(label: field.label, objects:)
    end
  end
end
