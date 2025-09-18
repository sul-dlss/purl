# frozen_string_literal: true

module Show
  module Description
    # A component for rendering resources related to the current object.
    class RelatedResourcesFieldComponent < ViewComponent::Base
      def initialize(values:)
        @values = values
        super()
      end

      attr_accessor :values

      def render?
        values.present?
      end

      # If the related resource has a URL, render it as a labelled link.
      # Otherwise, render it using the nested presentation (e.g. Parker citations).
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
