class IiifV2Controller < ApplicationController
  before_action :load_purl

  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlResource::ObjectNotReady, with: :object_not_ready

  def manifest
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    if @purl.iiif_manifest?
      manifest = Rails.cache.fetch([@purl, @purl.updated_at.utc, 'iiif_v2', 'manifest'], expires_in: Settings.resource_cache.lifetime) do
        @purl.iiif_manifest.body(self).to_ordered_hash
      end

      render json: JSON.pretty_generate(manifest.as_json)
    else
      head :not_found
    end
  end

  def canvas
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    if @purl.iiif_manifest?
      manifest = Rails.cache.fetch([@purl, @purl.updated_at.utc, 'iiif_v2', 'canvas'], expires_in: Settings.resource_cache.lifetime) do
        @purl.iiif_manifest.canvas(controller: self, resource_id: params[:resource_id]).to_ordered_hash
      end

      render json: JSON.pretty_generate(manifest.as_json)
    else
      head :not_found
    end
  end

  def annotation_list
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    if @purl.iiif_manifest?
      manifest = Rails.cache.fetch([@purl, @purl.updated_at.utc, 'iiif_v2', 'annotation_list'], expires_in: Settings.resource_cache.lifetime) do
        @purl.iiif_manifest.annotation_list(controller: self, resource_id: params[:resource_id]).to_ordered_hash
      end

      render json: JSON.pretty_generate(manifest.as_json)
    else
      head :not_found
    end
  end

  def annotation
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    if @purl.iiif_manifest?
      manifest = Rails.cache.fetch([@purl, @purl.updated_at.utc, 'iiif_v2', 'annotation'], expires_in: Settings.resource_cache.lifetime) do
        @purl.iiif_manifest.annotation(controller: self, annotation_id: params[:annotation_id]).to_ordered_hash
      end

      render json: JSON.pretty_generate(manifest.as_json)
    else
      head :not_found
    end
  end

  private

  # validate that the id is of the proper format
  def load_purl
    @purl = PurlResource.find(params[:id])
  end
end
