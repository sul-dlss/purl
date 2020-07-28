class PurlController < ApplicationController
  before_action :load_purl, except: [:index]

  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlResource::ObjectNotReady, with: :object_not_ready
  rescue_from ActionController::UnknownFormat, with: :missing_file

  def index; end

  # entry point into the application
  # rubocop:disable Metrics/AbcSize
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

      format.jpeg do
        if @purl.representative_thumbnail?
          redirect_to @purl.representative_thumbnail
        else
          redirect_to view_context.image_path('sul-logo-stacked.svg')
        end
      end

      format.zip do
        redirect_to Settings.stacks.url + '/object/' + ERB::Util.url_encode(params[:id]) + '.zip'
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def file
    redirect_to Settings.stacks.url + '/file/druid:' + ERB::Util.url_encode(params[:id]) + '/' + ERB::Util.url_encode(params[:file])
  end

  private

  # validate that the id is of the proper format
  def load_purl
    @purl = PurlResource.find(params[:id])
  end
end
