# frozen_string_literal: true

module Show
  class BodyComponent < ViewComponent::Base
    def initialize(version:)
      @version = version
      super()
    end

    attr_accessor :version

    delegate :mods, :cocina, to: :version
  end
end
