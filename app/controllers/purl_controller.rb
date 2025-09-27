# frozen_string_literal: true

class PurlController < ApplicationController
  before_action :load_purl, except: [:index]
  before_action :load_version, only: %i[show metrics]
  before_action :fix_etag_header

  rescue_from ActionController::UnknownFormat, with: :missing_file

  FrontPageItem = Data.define(:purl, :title)
  # Landing page for purl.
  # Shows a list of selected druids.
  def index
    @front_page_items = Settings.landing_page_druids.map do |druid|
      purl = Purl.find(druid)
      FrontPageItem.new(purl: purl, title: purl.version(:head).display_title)
    end
  end

  # entry point into the application
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def show
    return unless stale?(last_modified: @version.updated_at.utc, etag: @version.cache_key + "/#{@version.updated_at.utc}")

    maybe_add_flash_message!

    # render the landing page based on the format
    respond_to do |format| # rubocop:disable Metrics/BlockLength
      format.html

      format.xml do
        render xml: @version.public_xml_body
      end

      format.mods do
        render xml: @version.public_xml.mods.to_xml
      end

      format.meta_json do
        render json: @purl.meta_json, content_type: 'application/json'
      end

      format.json do
        if @version.withdrawn?
          render json: @version.withdrawn_cocina
        else
          render json: @version.cocina_body
        end
      end

      format.jpeg do
        # Lane is using these images. See: grep jpg /var/log/apache2/purl_access_ssl.log on the server
        if @version.representative_thumbnail?
          redirect_to @version.representative_thumbnail, allow_other_host: true
        else
          redirect_to view_context.image_path('sul-logo-stacked.svg')
        end
      end

      format.zip do
        redirect_to "#{Settings.stacks.url}/object/#{ERB::Util.url_encode(params[:id])}.zip", allow_other_host: true
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def file
    redirect_to "#{Settings.stacks.url}/file/druid:#{ERB::Util.url_encode(params[:id])}/#{ERB::Util.url_encode(params[:file])}", allow_other_host: true
  end

  def metrics
    render MetricsComponent.new(version: @version,
                                metrics: MetricsService.new.get_metrics(@version.druid))
  end

  private

  # validate that the id is of the proper format
  def load_purl
    @purl = Purl.find(params[:id])
  end

  def load_version
    @version = begin
      @purl.version(version_param)
    rescue ResourceRetriever::ResourceNotFound
      raise PurlVersion::ObjectNotReady, params[:id]
    end

    return if @version

    handle_missing_version!
    false
  end

  def missing_file
    render '/errors/missing_file', status: :not_found, formats: [:html]
  end

  def fix_etag_header
    # Apache adds -gzip to the etag header, which causes the request appear stale.
    request.headers['HTTP_IF_NONE_MATCH'].sub!('-gzip', '') if request.if_none_match
  end

  def version_param
    params[:version].presence || :head
  end

  def handle_missing_version!
    respond_to do |format|
      format.html do
        redirect_to purl_url(@purl), flash: { error: "Requested version '#{version_param}' not found. Showing latest version instead." }
      end
      format.all do
        head :not_found
      end
    end
  end

  def maybe_add_flash_message!
    if @version.withdrawn?
      flash.now[:alert] = '<b>This version has been withdrawn</b><br>' \
                          "Please visit #{view_context.link_to purl_url(@purl), purl_url(@purl)} to view the other versions of this item."
    elsif !@version.head?
      flash.now[:alert] = 'A newer version of this item is available.<br>' \
                          "#{view_context.link_to 'View latest version', purl_url(@purl)}"
    end
  end
end
