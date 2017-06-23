require 'iiif/presentation'

class Iiif3PresentationManifest < IiifPresentationManifest
  # Bypass this method if there are no image resources in contentMetadata
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def body(controller = nil)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    manifest_data = {
      '@id'   => controller.iiif3_manifest_url(druid), # DIFF from v2
      'label' => title,
      'attribution' => copyright || 'Provided by the Stanford University Libraries',
      'logo' => {
        '@id' => 'https://stacks.stanford.edu/image/iiif/wy534zh7137%2FSULAIR_rosette/full/400,/0/default.jpg',
        'service' => iiif_service('https://stacks.stanford.edu/image/iiif/wy534zh7137%2FSULAIR_rosette')
      },
      'seeAlso' => {
        '@id' => controller.purl_url(druid, format: 'mods'),
        'format' => 'application/mods+xml'
      }
    }

    manifest = IIIF::Presentation::Manifest.new manifest_data

    # Set viewingHint to paged if this is a book
    manifest.viewingHint = 'paged' if type == 'book'

    manifest.metadata = dc_to_iiif_metadata if dc_to_iiif_metadata.present?

    manifest.description = description_or_note

    sequence = IIIF::Presentation::Sequence.new(
      '@id' => "#{purl_base_uri}#sequence-1",
      'label' => 'Current order'
    )

    manifest.thumbnail = thumbnail_resource

    # for each resource image, create a canvas
    page_images.each do |resource|
      next unless purl_resource.rights.world_rights_for_file(resource.filename).first ||
                  purl_resource.rights.stanford_only_rights_for_file(resource.filename).first

      sequence.canvases << canvas_for_resource(purl_base_uri, resource)
    end

    manifest.sequences << sequence
    manifest
  end

  def canvas_for_resource(purl_base_uri, resource)
    canv = IIIF::Presentation::Canvas.new
    canv['@id'] = "#{purl_base_uri}/iiif3/canvas/#{resource.id}" # DIFF from v2
    canv.label = resource.label
    canv.label = 'image' unless canv.label.present?
    canv.height = resource.height
    canv.width = resource.width

    anno = annotation_for_resource(purl_base_uri, resource)
    anno['on'] = canv['@id']
    canv.images << anno
    canv
  end

  def annotation_for_resource(purl_base_uri, resource)
    url = stacks_iiif_base_url(resource.druid, resource.filename)

    anno = IIIF::Presentation::Annotation.new
    anno['@id'] = "#{purl_base_uri}/iiif3/annotation/#{resource.id}" # DIFF from v2

    img_res = IIIF::Presentation::ImageResource.new
    img_res['@id'] = "#{url}/full/full/0/default.jpg"
    img_res.format = 'image/jpeg'
    img_res.height = resource.height
    img_res.width = resource.width

    img_res.service = iiif_service(url)

    unless purl_resource.rights.world_rights_for_file(resource.filename).first
      img_res.service['service'] = [
        IIIF::Service.new(
          '@id' => "#{Settings.stacks.url}/auth/iiif",
          'profile' => 'http://iiif.io/api/auth/1/login',
          'label' => 'Stanford-affiliated? Login to view',
          'service' => [{
            '@id' => "#{Settings.stacks.url}/image/iiif/token",
            'profile' => 'http://iiif.io/api/auth/1/token'
          }]
        )
      ]
    end

    anno.resource = img_res
    anno
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
