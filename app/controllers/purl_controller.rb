class PurlController < ApplicationController
  before_action :load_purl, except: [:index]

  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlResource::ObjectNotReady, with: :object_not_ready
  rescue_from ActionController::UnknownFormat, with: :missing_file

  def index; end

  # entry point into the application
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
  def show
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

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
          head :not_found
        end
      end

      format.flipbook do
        if @purl.flipbook?
          render json: @purl.flipbook
        else
          head :not_found
        end
      end

      format.jpeg do
        if @purl.representative_thumbnail?
          redirect_to @purl.representative_thumbnail
        else
          redirect_to view_context.image_path('SUL-logo-stacked@2x.png')
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity

  def manifest
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    if @purl.iiif_manifest?
      manifest = Rails.cache.fetch([@purl, @purl.updated_at.utc], expires_in: Settings.resource_cache.lifetime) do
        @purl.iiif_manifest.body(self).to_ordered_hash
      end

      render json: manifest
    else
      head :not_found
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
    render '/errors/missing_file.html', status: 404
  end
end
