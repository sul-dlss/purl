require 'dor/util'

class EmbedController < ApplicationController
  include ImgEmbedHtmlHelper
  include PurlHelper

  self.asset_host = Settings.embed_host

  protect_from_forgery except: :embed_html_json

  before_action :validate_id, except: [:purl_embed_jquery_plugin]
  before_action :load_purl, except: [:purl_embed_jquery_plugin]
  before_action :validate_image, except: [:purl_embed_jquery_plugin]

  def show
    render layout: 'purl_embed'
  end

  def embed_js
    render layout: 'purl_embed_js'
  end

  def purl_embed_jquery_plugin
    redirect_to view_context.javascript_path('purl_embed_jquery_plugin')
  end

  def embed_html_json
    response.headers['Content-Type'] = 'application/javascript'
    render json: imgEmbedHtml, callback: params.fetch(:callback, 'callback')
  end

  private

  # validate that the id is of the proper format
  def validate_id
    unless Dor::Util.validate_druid(params[:id])
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

  def validate_image
    render_404 unless @purl.image?
  end

  def render_404
    render status: 404, file: "#{Rails.root}/public/404", formats: [:html], layout: false
  end
end
