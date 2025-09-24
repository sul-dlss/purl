# frozen_string_literal: true

require 'addressable/template'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_feedback_form?
    Settings.feedback.email_to.present? && !current_page?(feedback_path)
  end

  def link_to_purl(druid)
    link_to PurlResource.find(druid).version(:head).display_title, purl_url(druid), class: 'su-underline'
  rescue StandardError
    link_to druid, purl_url(druid), class: 'su-underline'
  end

  # Create the URL to pass to the embed service.  The embed service will create the viewer we display on the page.
  def embeddable_url(druid, version_id)
    args = Rails.env.development? ? { host: 'purl.stanford.edu' } : {}
    return version_purl_url(druid, version_id, args) if request.path == version_purl_path(druid, version_id)

    purl_url(druid, args)
  end
end
