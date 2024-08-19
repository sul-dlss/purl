class IiifController < ApplicationController
  before_action :load_purl
  before_action :load_version

  def manifest
    iiif_version = params[:iiif_version] == 'v3' ? 3 : 2

    return unless stale?(last_modified: @version.updated_at.utc, etag: "#{@version.cache_key}/#{iiif_version}/#{@version.updated_at.utc}")

    # Avoid trying to create a manifest for geo objects, because we don't yet have a way of knowing which file is a primary.
    # See ContentMetadata::GroupedResource#primary
    return head :not_found if @version.type == 'geo'

    manifest = Rails.cache.fetch(cache_key('manifest', iiif_version), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.body.to_ordered_hash
    end

    render json: JSON.pretty_generate(manifest.as_json)
  rescue IIIF::V3::Presentation::MissingRequiredKeyError
    # If the object has no published files, the manifest will not be valid.
    head :not_found
  end

  def canvas
    @version = @purl.version(:head)
    return unless stale?(last_modified: @version.updated_at.utc, etag: @version.cache_key + "/#{@version.updated_at.utc}")

    manifest = Rails.cache.fetch(cache_key('canvas'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.canvas(resource_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  # Only available for IIIF v3 manifests
  def annotation_page
    @version = @purl.version(:head)
    return unless stale?(last_modified: @version.updated_at.utc, etag: @version.cache_key + "/#{@version.updated_at.utc}")
    return head :not_found unless iiif_manifest.is_a?(Iiif3PresentationManifest)

    manifest = Rails.cache.fetch(cache_key('annotation_page'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation_page(annotation_page_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  def annotation_list
    @version = @purl.version(:head)
    return unless stale?(last_modified: @version.updated_at.utc, etag: @version.cache_key + "/#{@version.updated_at.utc}")

    manifest = Rails.cache.fetch(cache_key('annotation_list'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation_list(resource_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  def annotation
    @version = @purl.version(:head)
    return unless stale?(last_modified: @version.updated_at.utc, etag: @version.cache_key + "/#{@version.updated_at.utc}")

    manifest = Rails.cache.fetch(cache_key('annotation'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation(annotation_id: params[:resource_id])&.to_ordered_hash
    end
    return head :not_found unless manifest

    render json: JSON.pretty_generate(manifest.as_json)
  end

  private

  def cache_key(*args)
    [@version, @version.updated_at.utc, controller_name, *args, params[:resource_id]].compact
  end

  def iiif_manifest
    @iiif_manifest ||= if params[:iiif_version] == 'v3'
                         @version.iiif3_manifest(controller: self, iiif_namespace: params[:iiif_scope] == 'iiif3' ? :iiif3 : :iiif)
                       else
                         @version.iiif_manifest(controller: self)
                       end
  end

  # validate that the id is of the proper format
  def load_purl
    @purl = PurlResource.find(params[:purl_id] || params[:id])
  end

  def load_version
    @version = @purl.version(:head)
    raise PurlVersion::ObjectNotReady, params[:id] unless @version.ready?
  end
end
