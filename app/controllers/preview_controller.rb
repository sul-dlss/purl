# frozen_string_literal: true

class PreviewController < ApplicationController
  def index; end

  def show
    @mods = ModsDisplay::Record.new(params[:mods]).mods_display_html
    @purl = @document = PreviewResource.new(@mods)
  end

  def self.local_prefixes
    [controller_path, 'purl']
  end
end
