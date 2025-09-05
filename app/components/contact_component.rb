# frozen_string_literal: true

class ContactComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  # TODO: https://github.com/sul-dlss/cocina_display/issues/97
  def contacts
    @contacts ||= Array(version.cocina.dig('description', 'access', 'accessContact')).select { it['type'] == 'email' }
  end

  def render?
    contacts.present?
  end
end
