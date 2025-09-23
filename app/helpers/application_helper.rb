# frozen_string_literal: true

require 'addressable/template'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def application_name
    'Stanford Digital Repository'
  end

  def show_feedback_form?
    Settings.feedback.email_to.present? && !current_page?(feedback_path)
  end

  def link_to_purl(druid)
    link_to PurlResource.find(druid).version(:head).display_title, purl_url(druid), class: 'su-underline'
  rescue StandardError
    link_to druid, purl_url(druid), class: 'su-underline'
  end

  def oembed_url_template
    @oembed_url_template ||= Addressable::Template.new(Settings.embed.url_template)
  end

  def oembed_url_template_options
    params.permit(*Settings.embed.application_options.to_h.keys).to_h
  end

  def oembed_provider_url(options = {})
    oembed_url_template.expand(format: 'json', application_options: Settings.embed.application_options.to_h.merge(options))
  end

  def iframe_url_template
    @iframe_url_template ||= Addressable::Template.new(Settings.embed.iframe.url_template)
  end

  def iframe_url(druid, version_id = nil)
    iframe_url_template.expand(url: embeddable_url(druid, version_id))
  end

  def embeddable_url(druid, version_id = nil)
    if Settings.embed.url
      format(Settings.embed.url, druid:).tap do |embed_url|
        return "#{embed_url}/version/#{version_id}" if version_id.present? && request.path == version_purl_path(druid, version_id)
      end
    else
      version_id.present? ? version_purl_url(druid, version_id) : purl_url(druid)
    end
  end
end
