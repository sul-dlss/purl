require 'addressable/template'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def render_page_title
    if content_for?(:title)
      content_for(:title) + ' - ' + application_name
    else
      application_name
    end
  end

  def application_name
    'Stanford Digital Repository'
  end

  def show_feedback_form?
    Settings.feedback.email_to.present?
  end

  def link_to_purl druid
    link_to PurlResource.find(druid).title, purl_url(druid)
  end

  def with_copyright_symbol(str)
    str.gsub /\(c\) Copyright/i, '© Copyright'
  end

  def needs_download_panel?
    Settings.embed.needs_downloadable_file_panel_types.include? @purl.type
  end
end
