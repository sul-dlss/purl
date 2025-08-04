# frozen_string_literal: true

class FlashMessageComponent < ViewComponent::Base
  TYPES = [:success, :notice, :error, :alert].freeze

  def initialize(flash:)
    @flash = flash
    super()
  end

  def render?
    !@flash.empty?
  end

  def each_type
    TYPES.each do |level|
      yield @flash[level], bs_class(level) if @flash[level]
    end
  end

  def bs_class(level)
    case level
    when :success then 'alert-success'
    when :notice  then 'alert-info'
    when :alert   then 'alert-warning'
    when :error   then 'alert-danger'
    else "alert-#{level}"
    end
  end
end
