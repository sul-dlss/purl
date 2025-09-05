# frozen_string_literal: true

class ContactComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version
  delegate :contact_email_display_data, to: :cocina_display

  def render?
    contact_email_display_data.present?
  end
end
