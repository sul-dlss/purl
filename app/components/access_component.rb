# frozen_string_literal: true

class AccessComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  delegate :mods, to: :document

  def access_conditions
    mods&.accessCondition
  end

  def copyright?
    document.copyright? && (mods.blank? || access_conditions.none? { |x| x.label =~ /Copyright/i })
  end

  def use_and_reproduction?
    document.use_and_reproduction? && (mods.blank? || access_conditions.none? { |x| x.label =~ /Use and Reproduction/i })
  end

  def render_access_conditions
    safe_join(access_conditions.map { |access_condition| render_field(access_condition) })
  end

  def render_field(access_condition)
    value_transformer = ->(text) { stylize_links(format_mods_html(text, field: access_condition)) }
    render ModsDisplay::FieldComponent.new(field: access_condition, value_transformer:)
  end

  def render?
    access_conditions.present? || copyright? || use_and_reproduction?
  end

  def use_and_reproduction
    stylize_links(helpers.link_urls_and_email(document.use_and_reproduction))
  end

  def stylize_links(text)
    text.gsub('<a href=', '<a class="su-underline" href=').html_safe # rubocop:disable Rails/OutputSafety
  end

  def copyright
    document.copyright.gsub(/\(c\) Copyright/i, '© Copyright')
  end
end
