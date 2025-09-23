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

      def child_components
        related_resources.map { child_component it }
      end

      # If the related resource has a URL, render it as a labelled link.
      # Otherwise, render it using the nested presentation (e.g. Parker citations).
      # @param [CocinaDisplay::RelatedResource] related_resource
      def child_component(related_resource)
        if related_resource.url?
          LabelledLinkComponent.new(url: related_resource.url, link_text: related_resource.to_s)
        else
          RelatedResourceComponent.new(related_resource: related_resource)
        end
      end
    end
  end
end
