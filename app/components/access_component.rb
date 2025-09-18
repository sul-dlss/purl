# frozen_string_literal: true

class AccessComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
    super()
  end

  attr_reader :version

  delegate :license, :copyright?, :use_and_reproduction?, to: :version

  def render?
    license.present? || copyright? || use_and_reproduction?
  end

  def use_and_reproduction
    stylize_links(helpers.link_urls_and_email(version.use_and_reproduction))
  end

  def stylize_links(text)
    text.gsub('<a href=', '<a class="su-underline" href=').html_safe # rubocop:disable Rails/OutputSafety
  end

  def copyright
    version.copyright.gsub(/\(c\) Copyright/i, '© Copyright')
  end

  def license_description
    License.new(url: license).description
  end
end
