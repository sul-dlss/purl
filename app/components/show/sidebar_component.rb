# frozen_string_literal: true

module Show
  class SidebarComponent < ViewComponent::Base
    def initialize(version:, purl:)
      @version = version
      @purl = purl
      super()
    end

    attr_accessor :version, :purl

    delegate :releases, to: :purl
    delegate :released_to_searchworks?, to: :releases
    delegate :mods, to: :version

    def metrics?
      version.embeddable? || version.show_download_metrics? || version.doi.present?
    end
  end
end
