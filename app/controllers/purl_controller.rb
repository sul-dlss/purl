require "dor/util"

class PurlController < ApplicationController
  include ModsDisplay::ControllerExtension
  before_filter :validate_id
  before_filter :load_purl

  # entry point into the application
  def index
    # validate that the metadata is ready for delivery

    if @purl.is_ready?

      # render the landing page based on the format
      respond_to do |format|

        format.html {
          # if the object is an image, render image specific layout
          if @purl.is_image?
            render "/purl/image/_contents", layout: "layouts/purl_image"
          elsif @purl.is_book?
            render "/purl/flipbook/_contents", :layout => "purl_flipbook"
          end
        }

        format.xml {
          render :xml => @purl.public_xml
        }

        format.mods {
          if @purl.has_mods
            render :xml => @purl.mods_xml
          else
            render_404
          end
        }

        format.flipbook {
          if @purl.is_book?
            render :json => @purl.flipbook_json
          else
            render :json => nil
          end
        }
      end
    else
      render :partial => "purl/unavailable", :layout => "purl_image"
      return false
    end
  end

  private

  # validate that the id is of the proper format
  def validate_id
    # handle a single static grandfathered exception
    if params[:id] == 'ir:rs276tc2764'
      redirect_to "/ir:rs276tc2764/index.html"
      return
    end

    if !Dor::Util.validate_druid(params[:id])
      render_404('invalid')
      return false
    end
    true
  end

  def load_purl
    puts 'id:'+params[:id]
    @purl = PurlObject.find(params[:id])

    # Catch well formed druids that don't exist in the document cache
    if @purl.nil?
      render_404('unavailable')
      return false
    end
    true
  end

  def render_404(type)
    render :status => 404, :partial => "purl/" + type, :layout => "application"
  end

end

