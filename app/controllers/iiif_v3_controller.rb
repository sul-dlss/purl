class IiifV3Controller < IiifV2Controller
  private

  def iiif_manifest
    @purl.iiif3_manifest
  end
end
