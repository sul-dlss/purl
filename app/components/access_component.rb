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
    @use_and_reproduction ||= auto_link(simple_format(cocina_display.use_and_reproduction), class: 'su-underline')
  end

  def copyright
    @copyright ||= cocina_display.copyright&.gsub(/\(c\) Copyright/i, '© Copyright')
  end
end
