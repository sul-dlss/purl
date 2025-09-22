# frozen_string_literal: true

module Show
  module Description
    # A component for rendering a resource related to the current object.
    class RelatedResourceComponent < ViewComponent::Base
      def initialize(related_resource:)
        @related_resource = related_resource
        super()
      end

      attr_accessor :related_resource

      def render?
        related_resource.present?
      end
    end
  end
end
