require "dor/util"

class EmbedController < ApplicationController
  include ImgEmbedHtmlHelper
  include PurlHelper

  self.asset_host = Settings.embed_host
  
  protect_from_forgery except: :embed_html_json

  before_filter :validate_id, except: [:purl_embed_jquery_plugin]
  before_filter :load_purl, except: [:purl_embed_jquery_plugin]

  def index
    if @purl.image?
      render "purl/embed/_img_viewer", :layout => "purl_embed"
    else
      render_404
    end
  end

  def purl_embed_jquery_plugin
    redirect_to view_context.javascript_path('purl_embed_jquery_plugin')
  end

  def embed_html_json
    if @purl.image?
      response.headers["Content-Type"] = "application/javascript"
      render json: imgEmbedHtml, callback: params.fetch(:callback, 'callback')
    else
      render_404
    end
  end


  def embed_js
    if @purl.image?
      render "purl/embed/_img_viewer", :layout => "purl_embed_js"
    else
      render_404
    end
  end

  # validate that the id is of the proper format
  def validate_id
    if !Dor::Util.validate_druid(params[:id])
      render_404
      return false
    end
    true
  end

  def load_purl
    @purl = PurlObject.find(params[:id])

    # Catch well formed druids that don't exist in the document cache
    if @purl.nil?
      render_404
      return false
    end
    true
  end

  def render_404
    render :status => 404, :file => "#{Rails.root}/public/404", :formats => [:html], :layout => false
  end

end
