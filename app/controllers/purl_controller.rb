class PurlController < ApplicationController
  before_action :load_purl, except: [:index]
  before_action :fix_etag_header

  rescue_from ActionController::UnknownFormat, with: :missing_file

  # Landing page for purl.
  # Shows a list of selected druids.
  def index; end

  # entry point into the application
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def show
    @version = @purl.version(version_param) || default_version
    return unless stale?(last_modified: @version.updated_at.utc, etag: @version.cache_key + "/#{@version.updated_at.utc}")

    maybe_add_flash_message!

    # render the landing page based on the format
    respond_to do |format|
      format.html

      format.xml do
        render xml: @version.public_xml_body
      end

      format.mods do
        if @version.mods?
          render xml: @version.public_xml.mods.to_xml
        else
          head :not_found
        end
      end

      format.meta_json do
        render json: @purl.meta_json, content_type: 'application/json'
      end

      format.json do
        if @version.withdrawn?
          render json: withdrawn_cocina
        elsif @version.cocina?
          render json: @version.cocina_body
        else
          head :not_found
        end
      end

      format.jpeg do
        if @version.representative_thumbnail?
          redirect_to @version.representative_thumbnail, allow_other_host: true
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

  def metrics
    render 'purl/_metrics', locals: { document: @purl.version(:head) }
  end

  private

  # validate that the id is of the proper format
  def load_purl
    @purl = PurlResource.find(params[:id])
  end

  def missing_file
    render '/errors/missing_file', status: :not_found, formats: [:html]
  end

  def fix_etag_header
    # Apache adds -gzip to the etag header, which causes the request appear stale.
    request.headers['HTTP_IF_NONE_MATCH'].sub!('-gzip', '') if request.if_none_match
  end

  def version_param
    return :head if params[:version].blank?

    # Remove the 'v' part of the version param, e.g., 'v22'
    params[:version][/\d+/]
  end

  def default_version
    flash.now[:error] = "Requested version '#{version_param}' not found. Showing latest version instead."

    PurlVersion.new(id: params[:id], version_id: 1, head: true).tap do |version|
      raise PurlVersion::ObjectNotReady, id unless version.ready?
    end
  end

  def maybe_add_flash_message!
    if @version.withdrawn?
      flash.now[:alert] = '<b>This version has been withdrawn</b><br>' \
                          "Please visit #{view_context.link_to purl_url(@purl), purl_url(@purl)} to view the other versions of this item."
    elsif !@version.head?
      flash.now[:alert] = 'A newer version of this item is available'
    end
  end

  # Extracts the minimal cocina JSON for a withdrawn version
  # setting the status to 'withdrawn'
  def withdrawn_cocina
    cocina_json = JSON.parse(@version.cocina_body)

    {
      type: cocina_json['type'],
      externalIdentifier: cocina_json['externalIdentifier'],
      label: cocina_json['label'],
      version: cocina_json['version'],
      status: 'withdrawn',
      structural: { contains: [] }
    }.to_json
  end
end
