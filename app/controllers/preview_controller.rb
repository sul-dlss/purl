class PreviewController < ApplicationController
  def index; end

  def show
    @mods = ModsDisplayObject.new(params[:mods])
    @mods = @mods.render_mods_display(@mods)
    @purl = @document = OpenStruct.new(
      mods?: true,
      mods: @mods,
      title: Array.wrap(@mods.title).join(' -- ')
    )

    @purl.define_singleton_method(:released_to?) do |*args|
    end
  end

  def self.local_prefixes
    [controller_path, '/purl']
  end
end
