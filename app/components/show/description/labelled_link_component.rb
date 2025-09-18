# frozen_string_literal: true

module Show
  module Description
    # A component for rendering an HTML link with custom link text.
    class LabelledLinkComponent < ViewComponent::Base
      def initialize(url:, link_text:)
        @url = url
        @link_text = link_text
        super()
      end

      attr_accessor :url, :link_text

      def render?
        url.present? && link_text.present?
      end
    end
  end
end
