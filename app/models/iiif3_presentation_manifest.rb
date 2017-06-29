require 'iiif/presentation'
require 'iiif/v3/presentation'

class Iiif3PresentationManifest < IiifPresentationManifest
  delegate :resources, to: :content_metadata

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def body(controller = nil)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    manifest_data = {
      'id' => controller.iiif3_manifest_url(druid),
      'label' => title,
      'attribution' => copyright || 'Provided by the Stanford University Libraries',
      'logo' => {
        'id' => 'https://stacks.stanford.edu/image/iiif/wy534zh7137%2FSULAIR_rosette/full/400,/0/default.jpg',
        'service' => iiif_service('https://stacks.stanford.edu/image/iiif/wy534zh7137%2FSULAIR_rosette')
      },
      'seeAlso' => {
        'id' => controller.purl_url(druid, format: 'mods'),
        'format' => 'application/mods+xml'
      }
    }

    manifest = IIIF::V3::Presentation::Manifest.new manifest_data

    # Set viewingHint to paged if this is a book
    manifest.viewingHint = 'paged' if type == 'book'

    manifest.metadata = dc_to_iiif_metadata if dc_to_iiif_metadata.present?

    manifest.description = description_or_note

    sequence = IIIF::V3::Presentation::Sequence.new(
      'id' => "#{purl_base_uri}#sequence-1",
      'label' => 'Current order'
    )

    manifest.thumbnail = thumbnail_resource

    # for each resource image, create a canvas
    resources.each do |resource|
      sequence.canvases << canvas_for_resource(purl_base_uri, resource)
    end

    manifest.sequences << sequence
    manifest
  end

  def canvas_for_resource(purl_base_uri, resource)
    canv = IIIF::V3::Presentation::Canvas.new
    canv['id'] = "#{purl_base_uri}/iiif3/canvas/#{resource.id}"
    canv.label = resource.label
    canv.label = 'image' unless canv.label.present?
    if image?(resource)
      canv.height = resource.height
      canv.width = resource.width
    end

    anno_page = IIIF::V3::Presentation::AnnotationPage.new
    anno_page['id'] = "#{purl_base_uri}/iiif3/annotation_page/#{resource.id}"

    anno = annotation_for_resource(purl_base_uri, resource)
    anno['target'] = canv['id']

    anno_page.items << anno
    canv.content << anno_page
    canv
  end

  def annotation_for_resource(purl_base_uri, resource)
    anno = IIIF::V3::Presentation::Annotation.new
    anno['id'] = "#{purl_base_uri}/iiif3/annotation/#{resource.id}"

    anno.body = if image?(resource)
                  image_resource(resource)
                else
                  binary_resource(resource)
                end

    anno
  end

  def image_resource(resource)
    url = stacks_iiif_base_url(resource.druid, resource.filename)

    img_res = IIIF::V3::Presentation::ImageResource.new
    img_res['id'] = "#{url}/full/full/0/default.jpg"
    img_res.format = 'image/jpeg'
    img_res.height = resource.height
    img_res.width = resource.width

    img_res.service = iiif_service(url)

    unless purl_resource.rights.world_rights_for_file(resource.filename).first
      img_res.service['service'] = [
        IIIF::V3::Service.new(
          'id' => "#{Settings.stacks.url}/auth/iiif",
          'profile' => 'http://iiif.io/api/auth/1/login',
          'label' => 'Stanford-affiliated? Login to view',
          'service' => [{
            'id' => "#{Settings.stacks.url}/image/iiif/token",
            'profile' => 'http://iiif.io/api/auth/1/token'
          }]
        )
      ]
    end

    img_res
  end

  def binary_resource(resource)
    bin_res = IIIF::V3::Presentation::Resource.new
    bin_res['id'] = "#{Settings.stacks.url}/file/#{resource.druid}/#{resource.filename}"
    bin_res['type'] = 'Document'
    bin_res.format = resource.mimetype

    unless purl_resource.rights.world_rights_for_file(resource.filename).first
      bin_res.service = IIIF::V3::Service.new(
        'id' => "#{Settings.stacks.url}/auth/iiif",
        'profile' => 'http://iiif.io/api/auth/1/login',
        'label' => 'Stanford-affiliated? Login to view',
        'service' => [{
          'id' => "#{Settings.stacks.url}/image/iiif/token",
          'profile' => 'http://iiif.io/api/auth/1/token'
        }]
      )
    end
    bin_res
  end

  def thumbnail_resource
    return unless thumbnail_image

    thumb = IIIF::V3::Presentation::ImageResource.new
    thumb['type'] = 'Image'
    thumb['id'] = "#{thumbnail_base_uri}/full/!400,400/0/default.jpg"
    thumb.format = 'image/jpeg'
    thumb.service = iiif_service(thumbnail_base_uri)

    thumb
  end

  def iiif_service(id)
    IIIF::V3::Service.new(
      '@context' => 'http://iiif.io/api/image/2/context.json',
      '@id' => id,
      'id' => id,
      'profile' => Settings.stacks.iiif_profile
    )
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
