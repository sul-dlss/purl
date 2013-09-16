require "dor/util"

class PurlController < ApplicationController
  include ModsDisplay::ControllerExtension
  before_filter :validate_id
  before_filter :load_purl


  #this empty config block is recommended by jkeck due to potential misconfiguration without it. That should be fixed in >= 0.1.4
  configure_mods_display do
  end

  # entry point into the application
  def index
    # validate that the metadata is ready for delivery

    if @purl.is_ready?

      # render the landing page based on the format
      respond_to do |format|

        format.html {
          # if the object is an image, render image specific layout
          if @purl.is_image?
            render :template => "/purl/image/_contents", :layout => "layouts/purl_image"
          elsif @purl.is_book?
            render :template => "/purl/flipbook/_contents", :layout => "purl_flipbook"
          end
        }

        format.xml {
          render :xml =>@purl.public_xml
        }

        format.mods {
          if @purl.has_mods
            render :xml => @purl.mods_xml
          else
            render_404('invalid')
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
      render "purl/_unavailable"
      return false
    end
  end

  private

  # validate that the id is of the proper format
  def validate_id
    # handle a single static grandfathered exception
    if params[:id] == 'ir:rs276tc2764'
      redirect_to "/rs276tc2764", action: "index"
      return
    end

    if !Dor::Util.validate_druid(params[:id])
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
    render "/purl/_" + type, :layout => "application", :status => 404
  end

  configure_mods_display do
    abstract do
      label_class "abstract"
      value_class "desc-content"
    end
  end

end

