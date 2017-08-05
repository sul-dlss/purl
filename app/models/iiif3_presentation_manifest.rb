require 'iiif/presentation'
require 'iiif/v3/presentation'

class Iiif3PresentationManifest < IiifPresentationManifest
  delegate :reading_order, :resources, to: :content_metadata

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
        'service' => iiif_image_v2_service('https://stacks.stanford.edu/image/iiif/wy534zh7137%2FSULAIR_rosette')
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
    order = reading_order

    sequence = IIIF::V3::Presentation::Sequence.new(
      'id' => "#{purl_base_uri}#sequence-1",
      'label' => 'Current order'
    )

    sequence.viewingDirection = case order
                                when nil
                                  VIEWING_DIRECTION['ltr']
                                else
                                  VIEWING_DIRECTION[order]
                                end

    manifest.thumbnail = [thumbnail_resource]

    # for each resource image, create a canvas
    resources.each do |resource|
      sequence.canvases << canvas_for_resource(purl_base_uri, resource)
    end

    manifest.sequences << sequence
    manifest
  end

  def annotation_page(controller: nil, annotation_page_id:)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    selected_resource = resources.find { |resource| resource.id == annotation_page_id }

    annotation_page_for_resource(purl_base_uri, selected_resource) if selected_resource
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
    canv.content << annotation_page_for_resource(purl_base_uri, resource)
    canv
  end

  def annotation_page_for_resource(purl_base_uri, resource)
    anno_page = IIIF::V3::Presentation::AnnotationPage.new
    anno_page['id'] = "#{purl_base_uri}/iiif3/annotation_page/#{resource.id}"
    anno_page.items << annotation_for_resource(purl_base_uri, resource)
    anno_page
  end

  def annotation_for_resource(purl_base_uri, resource)
    anno = IIIF::V3::Presentation::Annotation.new
    anno['id'] = "#{purl_base_uri}/iiif3/annotation/#{resource.id}"
    anno['target'] = "#{purl_base_uri}/iiif3/canvas/#{resource.id}"

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

    img_res.service = iiif_image_v2_service(url)
    img_res.service['service'] = []
    if purl_resource.rights.stanford_only_rights_for_file(resource.filename).first
      img_res.service['service'].append(iiif_stacks_login_service)
    end

    if purl_resource.rights.restricted_by_location?(resource.filename)
      img_res.service['service'].append(iiif_location_auth_service)
    end

    img_res
  end

  def binary_resource(resource)
    bin_res = IIIF::V3::Presentation::Resource.new
    bin_res['id'] = "#{Settings.stacks.url}/file/#{resource.druid}/#{resource.filename}"
    bin_res['type'] = 'Document'
    bin_res.format = resource.mimetype

    unless purl_resource.rights.world_rights_for_file(resource.filename).first
      bin_res.service = iiif_stacks_login_service
    end
    bin_res
  end

  def thumbnail_resource
    return unless thumbnail_image

    thumb = IIIF::V3::Presentation::ImageResource.new
    thumb['type'] = 'Image'
    thumb['id'] = "#{thumbnail_base_uri}/full/!400,400/0/default.jpg"
    thumb.format = 'image/jpeg'
    thumb.service = iiif_image_v2_service(thumbnail_base_uri)

    thumb
  end

  def iiif_image_v2_service(id)
    IIIF::V3::Presentation::Service.new(
      '@context' => 'http://iiif.io/api/image/2/context.json',
      '@id' => id, # need @id here due to v2 @context URI
      'id' => id,
      'profile' => Settings.stacks.iiif_profile
    )
  end

  def iiif_stacks_login_service
    IIIF::V3::Presentation::Service.new(
      '@context' => 'http://iiif.io/api/auth/1/context.json',
      'id' => "#{Settings.stacks.url}/auth/iiif",
      'profile' => 'http://iiif.io/api/auth/1/login',
      'label' => 'Log in to access all available features.',
      'confirmLabel' => 'Login',
      'failureHeader' => 'Unable to authenticate',
      'failureDescription' => 'The authentication service cannot be reached'\
        '. If your browser is configured to block pop-up windows, try allow'\
        'ing pop-up windows for this site before attempting to log in again.',
      'service' => [
        {
          '@id' => "#{Settings.stacks.url}/image/iiif/token",
          'profile' => 'http://iiif.io/api/auth/1/token'
        },
        {
          '@id' => "#{Settings.stacks.url}/auth/logout",
          'profile' => 'http://iiif.io/api/auth/1/logout',
          'label' => 'Logout'
        }
      ]
    )
  end

  def iiif_location_auth_service
    IIIF::V3::Presentation::Service.new(
      'profile' => 'http://iiif.io/api/auth/1/external',
      'label' => 'External Authentication Required',
      'failureHeader' => 'Restricted Material',
      'failureDescription' => 'Restricted content cannot be accessed from your location',
      'service' => [
        {
          '@id' => "#{Settings.stacks.url}/image/iiif/token",
          'profile' => 'http://iiif.io/api/auth/1/token'
        }
      ]
    )
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
