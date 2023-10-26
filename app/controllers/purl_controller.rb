class PurlController < ApplicationController
  before_action :load_purl, except: [:index]
  before_action :fix_etag_header

  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlResource::ObjectNotReady, with: :object_not_ready
  rescue_from ActionController::UnknownFormat, with: :missing_file

  def index; end

  # entry point into the application
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def show
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    # render the landing page based on the format
    respond_to do |format| # rubocop:disable Metrics/BlockLength
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

      format.json do
        if @purl.cocina?
          render json: @purl.cocina_body
        else
          head :not_found
        end
      end

      format.jpeg do
        if @purl.representative_thumbnail?
          redirect_to @purl.representative_thumbnail, allow_other_host: true
        else
          redirect_to view_context.image_path('sul-logo-stacked.svg')
        end
      end

      format.zip do
        redirect_to Settings.stacks.url + '/object/' + ERB::Util.url_encode(params[:id]) + '.zip', allow_other_host: true
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def file
    redirect_to Settings.stacks.url + '/file/druid:' + ERB::Util.url_encode(params[:id]) + '/' + ERB::Util.url_encode(params[:file]), allow_other_host: true
  end

  private

  # validate that the id is of the proper format
  def load_purl
    @purl = PurlResource.find(params[:id])
  end

  def missing_file
    render '/errors/missing_file', status: :not_found
  end

  def fix_etag_header
    # Apache adds -gzip to the etag header, which causes the request appear stale.
    request.headers['HTTP_IF_NONE_MATCH'].sub!('-gzip', '') if request.if_none_match
  end
end
