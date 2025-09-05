# frozen_string_literal: true

class AltmetricsComponent < ViewComponent::Base
  def initialize(purl_version:)
    @purl_version = purl_version
    super()
  end

  attr_reader :purl_version

  delegate :display_title, :authors, :doi_id, to: :purl_version
  delegate :cocina_display, :druid, to: :purl_version

  def publication_date
    event = cocina_display.admin_creation_event.presence
    return unless event

    date = event.dates.first

    # NOTE: we're trapping for a missing year due to (https://github.com/sul-dlss/cocina_display/issues/105)
    return date.date&.year if date

    Honeybadger.notify("Malformed Cocina data: No date node found in creation event at description.adminMetadata.event.*.date for: #{druid}")
    nil
  end
end
