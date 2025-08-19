# frozen_string_literal: true

class FindItComponent < ViewComponent::Base
  def initialize(document:, version:)
    @document = document
    @version = version
    super
  end

  attr_reader :document, :version

  delegate :catalog_key, to: :version
  delegate :released_to_searchworks?, :released_to_earthworks?, :druid, to: :document

  Link = Struct.new('Link', :label, :href)

  def releases
    @releases ||= [].tap do |links|
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
