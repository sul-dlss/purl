class IiifController < ApplicationController
  before_action :load_purl

  rescue_from PurlResource::DruidNotValid, with: :invalid_druid
  rescue_from PurlResource::ObjectNotReady, with: :object_not_ready

  def manifest
    iiif_version = params[:iiif_version] == 'v3' ? 3 : 2
    return unless stale?(last_modified: @purl.updated_at.utc, etag: "#{@purl.cache_key}/#{iiif_version}/#{@purl.updated_at.utc}")

    manifest = Rails.cache.fetch(cache_key('manifest', iiif_version), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.body.to_ordered_hash
    end

    render json: JSON.pretty_generate(manifest.as_json)
  end

  def canvas
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    manifest = Rails.cache.fetch(cache_key('canvas'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.canvas(resource_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  # Only available for IIIF v3 manifests
  def annotation_page
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")
    return head :not_found unless iiif_manifest.is_a?(Iiif3PresentationManifest)

    manifest = Rails.cache.fetch(cache_key('annotation_page'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation_page(annotation_page_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  def annotation_list
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    manifest = Rails.cache.fetch(cache_key('annotation_list'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation_list(resource_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  def annotation
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    manifest = Rails.cache.fetch(cache_key('annotation'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation(annotation_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  private

  def cache_key(*args)
    [@purl, @purl.updated_at.utc, controller_name, *args, params[:resource_id]].compact
  end

  def iiif_manifest
    @iiif_manifest ||= if params[:iiif_version] == 'v3'
                         @purl.iiif3_manifest(controller: self, iiif_namespace: params[:iiif_scope] == 'iiif3' ? :iiif3 : :iiif)
                       else
                         @purl.iiif_manifest(controller: self)
                       end
  end

  # validate that the id is of the proper format
  def load_purl
    @purl = PurlResource.find(params[:purl_id] || params[:id])
  end
end
