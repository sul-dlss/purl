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
    link_to PurlResource.find(druid).version(:head).title, purl_url(druid), class: 'su-underline'
  rescue StandardError
    link_to druid, purl_url(druid), class: 'su-underline'
  end

  def oembed_url_template
    @oembed_url_template ||= Addressable::Template.new(Settings.embed.url_template)
  end

  def oembed_provider_url(options = {})
    oembed_url_template.expand(format: 'json', application_options: Settings.embed.application_options.to_h.merge(options))
  end

  def iframe_url_template
    @iframe_url_template ||= Addressable::Template.new(Settings.embed.iframe.url_template)
  end

  def iframe_url(druid)
    iframe_url_template.expand(url: embeddable_url(druid))
  end

  def embeddable_url(druid)
    if Settings.embed.url
      Settings.embed.url % { druid: }
    else
      purl_url(druid)
    end
  end

  def with_copyright_symbol(str)
    str.gsub(/\(c\) Copyright/i, '© Copyright')
  end
end
