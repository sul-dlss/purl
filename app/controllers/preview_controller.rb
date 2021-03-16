class PreviewController < ApplicationController
  def index; end

  def show
    @mods = ModsDisplayObject.new(params[:mods])
  end
end
