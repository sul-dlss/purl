require 'addressable/template'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def application_name
    'Stanford Digital Repository'
  end

  def show_feedback_form?
    Settings.feedback.email_to.present?
  end

  def link_to_purl druid
    link_to PurlResource.find(druid).title, purl_url(druid)
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
      Settings.embed.url % { druid: druid }
    else
      purl_url(druid)
    end
  end

  def with_copyright_symbol(str)
    str.gsub /\(c\) Copyright/i, '© Copyright'
  end

  def needs_download_panel?
    Settings.embed.needs_downloadable_file_panel_types.include? @purl.type
  end
end
