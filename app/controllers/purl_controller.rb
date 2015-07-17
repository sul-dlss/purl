require 'dor/util'

class PurlController < ApplicationController
  include ModsDisplay::ControllerExtension
  before_action :validate_id
  before_action :load_purl

  # this empty config block is recommended by jkeck due to potential misconfiguration without it. That should be fixed in >= 0.1.4
  configure_mods_display do
  end

  # entry point into the application
  def index
    # validate that the metadata is ready for delivery

    if @purl.ready?

      # render the landing page based on the format
      respond_to do |format|
        format.html do
          # if the object is an image, render image specific layout
          if @purl.image?
            render template: '/purl/image/_contents', layout: 'layouts/purl_image'
          elsif @purl.book?
            render template: '/purl/flipbook/_contents', layout: 'purl_flipbook'
          end
        end

        format.xml do
          render xml: @purl.public_xml
        end

        format.mods do
          if @purl.has_mods
            render xml: @purl.mods_xml
          else
            render_404('invalid')
          end
        end

        format.flipbook do
          if @purl.is_book?
            render json: @purl.flipbook_json
          else
            render nothing: true, status: 404
          end
        end
      end
    else
      render 'purl/_unavailable'
      return false
    end
  end

  rescue_from(ActionController::UnknownFormat) do |_e|
    request.format = :html
    render_404('unknown_format')
  end

  def manifest
    if @purl.has_manifest
      render json: @purl.manifest_json
    else
      render nothing: true, status: 404
    end
  end

  private

  # validate that the id is of the proper format
  def validate_id
    # handle a single static grandfathered exception
    if params[:id] == 'ir:rs276tc2764'
      redirect_to '/rs276tc2764', action: 'index'
      return
    end

    unless Dor::Util.validate_druid(params[:id])
      render_404('invalid')
      return false
    end
    true
  end

  def load_purl
    @purl = PurlObject.find(params[:id])

    # Catch well formed druids that don't exist in the document cache
    if @purl.nil?
      render_404('unavailable')
      return false
    end
    true
  end

  def render_404(type)
    render '/purl/_' + type, layout: 'application', status: 404
  end

  configure_mods_display do
    abstract do
      label_class 'abstract'
      value_class 'desc-content'
    end
  end
end
