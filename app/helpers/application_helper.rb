# frozen_string_literal: true

require 'addressable/template'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def show_feedback_form?
    Settings.feedback.email_to.present? && !current_page?(feedback_path)
  end
end
