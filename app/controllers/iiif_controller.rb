# frozen_string_literal: true

class IiifController < ApplicationController
  before_action :load_purl
  before_action :load_version

  def manifest
    return unless stale?(last_modified: @version.updated_at.utc, etag: "#{@version.cache_key}/#{iiif_version}/#{@version.updated_at.utc}")
    return render json: { error: 'Not embeddable' }, status: :not_found unless @version.embeddable? || @version.collection?

    manifest = Rails.cache.fetch(cache_key('manifest', iiif_version), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.body.to_ordered_hash
    end
    render json: JSON.pretty_generate(manifest.as_json),
           content_type: "application/ld+json; profile=\"http://iiif.io/api/presentation/#{iiif_version}/context.json\""
  rescue IIIF::V3::Presentation::MissingRequiredKeyError
    # If the object has no published files, the manifest will not be valid.
    head :not_found
  end

  # Only available for IIIF v3 manifests
  def annotation_page
    @version = @purl.version(:head)
    return unless stale?(last_modified: @version.updated_at.utc, etag: @version.cache_key + "/#{@version.updated_at.utc}")
    return head :not_found unless iiif_manifest.is_a?(Iiif3PresentationManifest)

    manifest = Rails.cache.fetch(cache_key('annotation_page'), expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation_page(fileset_id: params[:resource_id])&.to_ordered_hash
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
    @iiif_manifest ||= if iiif_version == 3
                         @version.iiif3_manifest(controller: self, iiif_namespace: params[:iiif_scope] == 'iiif3' ? :iiif3 : :iiif)
                       else
                         @version.iiif_manifest(controller: self)
                       end
  end

  def iiif_version
    @iiif_version ||= if request.headers['accept'].include?('profile="http://iiif.io/api/presentation/3/context.json"') ||
                         params[:iiif_version] == 'v3'
                        3
                      else
                        2 # Default to IIIF 2.0 if no version is specified
                      end
  end

  # validate that the id is of the proper format
  def load_purl
    @purl = Purl.find(params[:purl_id] || params[:id])
  end

  def load_version
    @version = begin
      @purl.version(version_param)
    rescue ResourceRetriever::ResourceNotFound
      raise PurlVersion::ObjectNotReady, params[:id]
    end
    raise PurlVersion::ObjectNotReady, params[:id] unless @version.ready?
  end

  def version_param
    params[:version].presence || :head
  end
end
