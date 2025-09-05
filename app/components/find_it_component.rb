# frozen_string_literal: true

class FindItComponent < ViewComponent::Base
  def initialize(releases:, version:)
    @releases = releases
    @version = version
    super()
  end

  attr_reader :releases, :version

  delegate :catalog_key, :druid, to: :version
  delegate :released_to_searchworks?, :released_to_earthworks?, to: :releases

  Link = Struct.new('Link', :label, :href)

  def release_items
    @release_items ||= [].tap do |links|
      if released_to_searchworks? && !catalog_key
        links << Link.new(label: 'View in SearchWorks', href: searchworks_url(druid))
      elsif catalog_key
        links << Link.new(label: 'View in SearchWorks', href: searchworks_url(catalog_key))
      end
      links << Link.new(label: 'View in EarthWorks', href: earthworks_url) if released_to_earthworks?
    end
  end

  def searchworks_url(id)
    Kernel.format(Settings.searchworks.view_template_url, druid: id)
  end

  def earthworks_url
    Kernel.format(Settings.earthworks.view_template_url, druid:)
  end
end
