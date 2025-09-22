# frozen_string_literal: true

class AccessComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version
  delegate :license_description, to: :cocina_display

  def render?
    license_description.present? || copyright.present? || use_and_reproduction.present?
  end

  def use_and_reproduction
    @use_and_reproduction ||= stylize_links(auto_link(cocina_display.use_and_reproduction))
  end

  def stylize_links(text)
    text.gsub('<a href=', '<a class="su-underline" href=').html_safe # rubocop:disable Rails/OutputSafety
  end

  def copyright
    @copyright ||= cocina_display.copyright&.gsub(/\(c\) Copyright/i, '© Copyright')
  end
end
