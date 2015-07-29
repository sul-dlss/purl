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

  def embeddable_url(druid)
    Settings.embed.url % { druid: druid }
  end

  def with_copyright_symbol(str)
    str.gsub /\(c\) Copyright/i, '© Copyright'
  end
end
