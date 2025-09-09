# frozen_string_literal: true

module Show
  module Description
    class FieldComponent < ViewComponent::Base
      def initialize(values:, delimiter:)
        @values = values
        @delimiter = delimiter
        super()
      end

      attr_accessor :values, :delimiter

      def render?
        values.present?
      end
    end
  end
end
