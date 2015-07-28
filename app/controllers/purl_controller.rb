require 'dor/util'

class PurlController < ApplicationController
  before_action :load_purl, except: [:index]

  def index
  end

  # entry point into the application
  def show
    # validate that the metadata is ready for delivery

    # render the landing page based on the format
    respond_to do |format|
      format.html

      format.xml do
        render xml: @purl.public_xml_body
      end

      format.mods do
        if @purl.mods?
          render xml: @purl.mods_body
        else
          render_404('invalid')
        end
      end

      format.flipbook do
        if @purl.flipbook?
          render json: @purl.flipbook.to_json
        else
          render nothing: true, status: 404
        end
      end
    end
  end

  def manifest
    if @purl.iiif_manifest?
      render json: @purl.iiif_manifest_body
    else
      render nothing: true, status: 404
    end
  end

  private

  # validate that the id is of the proper format
  def load_purl
    unless Dor::Util.validate_druid(params[:id])
      render_404('invalid')
      return false
    end

    @purl = PurlResource.find(params[:id])

    # Catch well formed druids that don't exist in the document cache
    if @purl.nil? || !@purl.ready?
      render_404('unavailable')
      return false
    end

    true
  end

  def render_404(type)
    render '/errors/' + type, status: 404
  end
end
