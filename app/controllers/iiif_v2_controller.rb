class IiifV2Controller < ApplicationController
  before_action :load_purl

  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlResource::ObjectNotReady, with: :object_not_ready

  before_action :check_if_purl_manifest_needed

  def check_if_purl_manifest_needed
    head :not_found unless iiif_manifest.needed?
  end

  def manifest
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    cache_key = [@purl, @purl.updated_at.utc, 'iiif', iiif_version, 'manifest']
    manifest = Rails.cache.fetch(cache_key, expires_in: Settings.resource_cache.lifetime) do
      @purl.iiif_manifest(iiif_version).body(self).try(:to_ordered_hash)
    end

    if manifest
      render json: JSON.pretty_generate(manifest.as_json)
    else
      head :not_found
    end
  end

  def canvas
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    cache_key = [@purl, @purl.updated_at.utc, 'iiif', iiif_version, 'canvas', params[:resource_id]]
    manifest = Rails.cache.fetch(cache_key, expires_in: Settings.resource_cache.lifetime) do
      @purl.iiif_manifest(iiif_version).canvas(controller: self, resource_id: params[:resource_id]).try(:to_ordered_hash)
    end

    if manifest
      render json: JSON.pretty_generate(manifest.as_json)
    else
      head :not_found
    end
  end

  def annotation
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    cache_key = [@purl, @purl.updated_at.utc, 'iiif', iiif_version, 'annotation', params[:annotation_id]]
    manifest = Rails.cache.fetch(cache_key, expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation(controller: self, annotation_id: params[:annotation_id]).try(:to_ordered_hash)
    end

    if manifest
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

  def iiif_manifest
    @purl.iiif_manifest(iiif_version)
  end

  def iiif_version
    :v2
  end
end
