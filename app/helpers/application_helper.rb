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

  def stacks_url
    if params[:stacks] == 'b'
      Settings.stacks.url_b
    else
      Settings.stacks.url
    end
  end
end
