require "dor/util"

class EmbedController < ApplicationController
  include ImgEmbedHtmlHelper
  include PurlHelper

  before_filter :validate_id
  before_filter :load_purl

  def index
    if @purl.is_image?
      render :partial => "purl/embed/img_viewer", :layout => "purl_embed"
    else
      render_404
    end
  end

  def embed_html_json
    if @purl.is_image?
      render :json => imgEmbedHtml(params[:callback])
    else
      render_404
    end
  end


  def embed_js
    if @purl.is_image?
      render :partial => "purl/embed/img_viewer", :layout => "purl_embed_js"
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
    @purl = Purl.find(params[:id])

    # Catch well formed druids that don't exist in the document cache
    if @purl.nil?
      render_404
      return false
    end
    true
  end

  def render_404
    render :status => 404, :file => "#{RAILS_ROOT}/public/404.html"
  end

end