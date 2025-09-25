# frozen_string_literal: true

require 'addressable/template'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_feedback_form?
    Settings.feedback.email_to.present? && !current_page?(feedback_path)
  end

  def link_to_purl(druid)
    link_to Purl.find(druid).version(:head).display_title, purl_url(druid), class: 'su-underline'
  rescue StandardError
    link_to druid, purl_url(druid), class: 'su-underline'
  end

  # Create the URL to pass to the embed service.  The embed service will create the viewer we display on the page.
  def embeddable_url(purl_version)
    args = Rails.env.development? ? { host: 'purl.stanford.edu' } : {}
    versioned_path = version_purl_url(purl_version.druid, purl_version.version_id, args)

    current_page?(versioned_path) ? versioned_path : purl_url(purl_version.druid, args)
  end
end
