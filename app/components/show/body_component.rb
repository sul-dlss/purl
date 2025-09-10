# frozen_string_literal: true

module Show
  class BodyComponent < ViewComponent::Base
    def initialize(version:)
      @version = version
      super()
    end

    attr_accessor :version

    delegate :cocina, to: :version
  end
end
