class IiifV3Controller < IiifV2Controller
  def annotation_page
    return unless stale?(last_modified: @purl.updated_at.utc, etag: @purl.cache_key + "/#{@purl.updated_at.utc}")

    cache_key = [@purl, @purl.updated_at.utc, 'iiif_v3', 'annotation_page', params[:annotation_page_id]]
    manifest = Rails.cache.fetch(cache_key, expires_in: Settings.resource_cache.lifetime) do
      iiif_manifest.annotation_page(controller: self, annotation_page_id: params[:annotation_page_id]).try(:to_ordered_hash)
    end

    if manifest
      render json: JSON.pretty_generate(manifest.as_json)
    else
      head :not_found
    end
  end

  private

  def iiif_version
    :v3
  end
end
