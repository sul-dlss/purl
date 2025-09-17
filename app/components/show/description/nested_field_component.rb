# frozen_string_literal: true

module Show
  module Description
    class NestedFieldComponent < ViewComponent::Base
      def initialize(display_data:, delimiter:)
        @display_data = display_data
        @delimiter = delimiter
        super()
      end

      attr_accessor :display_data, :delimiter

      def render?
        display_data.present?
      end
    end
  end
end
