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
end
