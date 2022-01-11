class PreviewController < ApplicationController
  def index; end

  def show
    @mods = ModsDisplay::Record.new(params[:mods])
    @mods = @mods.mods_display_html
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
