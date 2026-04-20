# frozen_string_literal: true

module Show
  module Description
    # A component for rendering resources related to the current object.
    class RelatedResourcesFieldComponent < ViewComponent::Base
      # @param [CocinaDisplay::DisplayData] related_resources_field
      def initialize(related_resources_field:)
        @related_resources_field = related_resources_field
        super()
      end

      attr_accessor :related_resources_field

      delegate :label, to: :related_resources_field

      def render?
        related_resources_field.present?
      end

      # @return [Array<CocinaDisplay::RelatedResource>]
      def related_resources
        related_resources_field.objects
      end
    end
  end
end
