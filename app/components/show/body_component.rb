# frozen_string_literal: true

module Show
  class BodyComponent < ViewComponent::Base
    def initialize(mods:)
      @mods = mods
      super()
    end

    attr_accessor :mods
  end
end
