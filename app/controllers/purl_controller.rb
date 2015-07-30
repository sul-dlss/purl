require 'dor/util'

class PurlController < ApplicationController
  before_action :load_purl, except: [:index]

  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlResource::ObjectNotReady, with: :object_not_ready
  rescue_from ActionController::UnknownFormat, with: :missing_file

  def index
  end

  # entry point into the application
  def show
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    # render the landing page based on the format
    respond_to do |format|
      format.html

      format.xml do
        render xml: @purl.public_xml_body
      end

      format.mods do
        render xml: @purl.mods_body
      end if @purl.mods?

      format.flipbook do
        render json: @purl.flipbook.to_json
      end if @purl.flipbook?

      format.jpeg do
        if @purl.representative_thumbnail?
          redirect_to @purl.representative_thumbnail
        else
          redirect_to view_context.image_path('SUL-logo-stacked@2x.png')
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
    @purl = PurlResource.find(params[:id])
  end

  def invalid_druid
    render '/errors/invalid', status: 404
  end

  def object_not_ready
    render '/errors/unavailable', status: 404
  end

  def missing_file
    fail ActionController::RoutingError, 'Not Found'
  end
end
