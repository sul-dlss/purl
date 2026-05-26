# frozen_string_literal: true

class ContactComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :cocina_display, to: :version

  def render?
    cocina_display&.contact_email_display_data.present?
  end
end
