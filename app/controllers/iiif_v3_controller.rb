class IiifV3Controller < IiifController
  private

  def iiif_base_uri
    "#{purl_url(@purl.druid)}/iiif3"
  end

  def iiif_manifest
    @iiif_manifest ||= @purl.iiif3_manifest(iiif_base_uri:)
  end
end
