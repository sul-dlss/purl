require 'iiif/presentation'
require 'iiif/v3/presentation'

class Iiif3PresentationManifest < IiifPresentationManifest
  delegate :reading_order, to: :content_metadata
  attr_reader :purl_base_uri

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def body
    manifest_data = {
      'id' => manifest_url,
      'label' => { en: [title] },
      'requiredStatement' => {
        'label' => { en: ['Attribution'] },
        'value' => { en: attribution.compact_blank }
      },
      'provider' => [provider],
      'seeAlso' => [{
        'id' => controller.purl_url(druid, format: 'mods'),
        'type' => 'Metadata',
        'format' => 'application/mods+xml'
      }]
    }

    manifest_data['service'] = [content_search_service] if content_search_service
    if nav_place
      manifest_data['navPlace'] = nav_place
      manifest_data['@context'] = IIIF::V3::Presentation::CONTEXT + ['http://iiif.io/api/extension/navplace/context.json']
    end

    manifest = iiif_manifest_class.new(manifest_data)

    # Set behavior to paged if this is a book
    manifest['behavior'] = ['paged'] if type == 'book'
    (_collection, collection_head_version) = containing_purl_collections&.first
    collection_title = collection_head_version&.title
    metadata_writer = Iiif3MetadataWriter.new(cocina_descriptive: cocina['description'],
                                              published_date: updated_at,
                                              collection_title:,
                                              doi: cocina.dig('identification', 'doi'))
    manifest.metadata = metadata_writer.write

    manifest.summary = { en: [description_or_note] } if description_or_note.present?
    order = reading_order

    manifest.viewingDirection = case order
                                when nil
                                  VIEWING_DIRECTION['ltr']
                                else
                                  VIEWING_DIRECTION[order]
                                end

    manifest.thumbnail = [thumbnail_resource] if thumbnail_resource?

    build_canvases(manifest)

    manifest
  end

  # https://iiif.io/api/presentation/3.0/#provider
  def provider
    {
      'id' => 'https://library.stanford.edu/about',
      'type' => 'Agent',
      'label' => { 'en' => ['Stanford University Libraries'] },
      'homepage' => [
        {
          'id' => 'https://library.stanford.edu/',
          'type' => 'Text',
          'label' => { 'en' => ['Stanford University Libraries Homepage'] },
          'format' => 'text/html'
        }
      ],
      'logo' => [{
        'id' => 'https://stacks.stanford.edu/image/iiif/wy534zh7137/SULAIR_rosette/full/400,/0/default.jpg',
        'format' => 'image/jpeg',
        'type' => 'Image',
        'service' => [iiif_image_v2_service('https://stacks.stanford.edu/image/iiif/wy534zh7137/SULAIR_rosette').to_ordered_hash]
      }]
    }
  end

  def build_canvases(manifest)
    # for each resource sequence (SDR term), create a canvas
    if %w[geo file].include?(type)
      # Geo can't determine "primary", so we just create a "dummy" canvas here.
      # We don't use the canvases for the file viewer and it slows down the metadata viewer when there are a lot of files
      # IIIF v3 requires Manifests to have at least one canvas. https://iiif.io/api/presentation/3.0/#34-structural-properties
      resource = content_metadata.grouped_resources.first
      file = resource.files.first
      manifest.items << canvas_for_resource(file)
    elsif %w[book image map].include?(type)
      content_metadata.grouped_resources.each do |resource_group|
        file = resource(resource_group)
        if image?(file) && %w[image page].include?(file.type)
          manifest.items << canvas_for_resource(resource_group) if deliverable_file?(file)
        else
          manifest.rendering += image_rendering_for_resource_group(resource_group)
        end
      end
    else
      content_metadata.grouped_resources.each do |resource_group|
        manifest.items << canvas_for_resource(resource_group)
      end
    end
  end

  def attribution
    [copyright || 'Provided by the Stanford University Libraries'].flatten
  end

  def resources
    resources = content_metadata.resources

    resources.select! { |x| x.type == '3d' } if three_d?

    resources
  end

  def annotation_page(annotation_page_id:)
    selected_resource = resources.find { |resource| resource.id == annotation_page_id }

    annotation_page_for_resource(selected_resource) if selected_resource
  end

  def resource(resource_group)
    return resource_group.primary if resource_group.is_a? ContentMetadata::GroupedResource

    resource_group
  end

  def canvas_for_resource(resource_group)
    resource = resource(resource_group)

    canv = IIIF::V3::Presentation::Canvas.new
    canv['id'] = canvas_url(resource_id: resource.id)
    canv.label = {
      en: [resource.label.presence || 'image']
    }
    canv.rendering = []

    if image?(resource)
      canv.height = resource.height
      canv.width = resource.width
      if downloadable_file?(resource)
        canv.rendering += [binary_resource(
          resource,
          label: "Original source file (#{number_to_human_size(resource.size)})"
        ).to_ordered_hash]
      end
    end
    canv.items << annotation_page_for_resource(resource)

    if resource_group.is_a?(ContentMetadata::GroupedResource)
      thumbnail_canvas = thumbnail_canvas_for_resource_group(resource_group)
      canvas_type = resource.type == 'audio' ? 'accompanyingCanvas' : 'placeholderCanvas'
      canv[canvas_type] = thumbnail_canvas

      canv['annotations'] = supplementing_resources_annotation_page(resource_group)
      canv.rendering += renderings_for_resource_group(resource_group)
    end

    canv
  end

  def thumbnail_canvas_for_resource_group(resource_group)
    return unless resource_group.thumbnail_canvas

    thumbnail_canvas = IIIF::V3::Presentation::Canvas.new
    thumbnail_canvas['id'] = canvas_url(resource_id: resource_group.thumbnail_canvas.filename)
    thumbnail_canvas.label = {
      en: [resource_group.thumbnail_canvas.label.presence || 'image']
    }
    if image?(resource_group.thumbnail_canvas)
      thumbnail_canvas.height = resource_group.thumbnail_canvas.height
      thumbnail_canvas.width = resource_group.thumbnail_canvas.width
    end

    thumbnail_canvas.items << annotation_page_for_resource(resource_group.thumbnail_canvas)

    thumbnail_canvas
  end

  def supplementing_resources_annotation_page(resource_group)
    return unless resource_group.supplementing_resources.any?

    annotation_page = IIIF::V3::Presentation::AnnotationPage.new
    annotation_page['id'] = "#{annotation_page_url(resource_id: resource_group.primary.id)}/supplement"

    resource_group.supplementing_resources.each do |supplementing_resource|
      anno = annotation_for_resource(supplementing_resource)
      anno.id = annotation_url(resource_id: supplementing_resource.filename)
      anno.motivation = 'supplementing'
      annotation_page.items << anno
    end

    [annotation_page]
  end

  def renderings_for_resource_group(resource_group)
    resource_group.other_resources.map do |other_resource|
      binary_resource(other_resource).to_ordered_hash
    end
  end

  def image_rendering_for_resource_group(resource_group)
    resource_group.files.map do |resources|
      binary_resource(resources).to_ordered_hash
    end
  end

  def annotation_page_for_resource(resource)
    anno_page = IIIF::V3::Presentation::AnnotationPage.new
    anno_page['id'] = annotation_page_url(resource_id: resource.id)
    anno_page.items << annotation_for_resource(resource)
    anno_page
  end

  def annotation_for_resource(resource)
    anno = IIIF::V3::Presentation::Annotation.new
    anno['id'] = annotation_url(resource_id: resource.id)
    anno['target'] = canvas_url(resource_id: resource.id)

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

    img_res.service = [iiif_image_v2_service(url)]
    img_res.service[0]['services'] = []
    img_res.service[0]['services'].append(iiif_stacks_v1_login_service) if rights.stanford_only_rights_for_file(resource.filename).first

    img_res.service[0]['services'].append(iiif_location_auth_service) if rights.restricted_by_location?(resource.filename)

    img_res
  end

  def stacks_version
    @purl_version.version_id
  end

  def stacks_version_file_url(druid, filename)
    # we can only get versions paths in sul-embed if we pass a parameter.
    # if we are just doing purl/druid we need to return the simple path
    return stacks_file_url(druid, filename) if @purl_version.head?

    "#{Settings.stacks.url}/v2/file/#{druid}/version/#{stacks_version}/#{ERB::Util.url_encode(filename)}"
  end

  def binary_resource(resource, label: resource.filename)
    bin_res = IIIF::V3::Presentation::Resource.new
    file_url = stacks_version_file_url(resource.druid, resource.filename)
    bin_res['id'] = file_url
    bin_res['type'] = iiif_resource_type(resource)
    bin_res['label'] = { en: [label] }
    bin_res.format = resource.mimetype

    bin_res.service = [probe_service(resource, file_url)]

    bin_res
  end

  def probe_service(resource, file_url)
    IIIF::V3::Presentation::Service.new(
      'id' => "#{Settings.stacks.url}/iiif/auth/v2/probe?id=#{URI.encode_uri_component(file_url)}",
      'type' => 'AuthProbeService2',
      'errorHeading' => { 'en' => ['No access'] },
      'errorNote' => { 'en' => ['You do not have permission to access this resource'] }
    ).tap do |probe_service|
      probe_service.service = if rights.world_rights_for_file(resource.filename).first
                                # We only need this because a probe service MUST have one or more access services and
                                # we want to run the probe service so that it can redirect to the streaming server.
                                # See https://iiif.io/api/auth/2.0/#probe-service-description
                                [iiif_v2_access_service_external_public]
                              else
                                [iiif_v2_access_service_active]
                              end
    end
  end

  def iiif_resource_type(resource)
    case resource.mimetype
    when /^image/
      'Image'
    when /^video/
      'Video'
    when /^audio/
      'Sound'
    when /^text/, %r{^application/pdf}
      if three_d?
        'Dataset'
      else
        'Text'
      end
    when %r{^application/vnd.threejs\+json}
      'Model'
    else
      'Dataset'
    end
  end

  def thumbnail_resource
    return unless thumbnail_image

    thumb = IIIF::V3::Presentation::ImageResource.new
    thumb['type'] = 'Image'
    thumb['id'] = "#{thumbnail_base_uri}/full/!400,400/0/default.jpg"
    thumb.format = 'image/jpeg'
    thumb.service = [iiif_image_v2_service(thumbnail_base_uri)]
    if thumbnail_image.height >= thumbnail_image.width
      thumb.height = 400
      thumb.width = ((400.0 * thumbnail_image.width) / thumbnail_image.height).round
    else
      thumb.width = 400
      thumb.height = ((400.0 * thumbnail_image.height) / thumbnail_image.width).round
    end

    thumb
  end

  def thumbnail_resource?
    thumbnail_image.present?
  end

  def iiif_image_v2_service(id)
    IIIF::V3::Presentation::Service.new(
      'id' => id,
      'type' => 'ImageService2',
      'profile' => Settings.stacks.iiif_profile
    )
  end

  # The user will not be required to interact with an authentication system,
  # the client is expected to already have the authorizing aspect
  def iiif_v2_access_service_external_public
    IIIF::V3::Presentation::Service.new(
      'type' => 'AuthAccessService2',
      'profile' => 'external',
      'label' => { 'en' => ['Public users'] }
    ).tap do |service|
      service.service = [iiif_v2_access_token_service]
    end
  end

  # The user will be required to visit the user interface of an external authentication system.
  # https://iiif.io/api/auth/2.0/#active-interaction-pattern
  def iiif_v2_access_service_active
    IIIF::V3::Presentation::Service.new(
      'id' => "#{Settings.stacks.url}/auth/iiif",
      'type' => 'AuthAccessService2',
      'profile' => 'active',
      'label' => { 'en' => ['Stanford users: log in to access all available features'] },
      'confirmLabel' => { 'en' => ['Log in'] }
    ).tap do |service|
      service.service = [iiif_v2_access_token_service]
    end
  end

  def iiif_v2_access_token_service
    IIIF::V3::Presentation::Service.new(
      'id' => "#{Settings.stacks.url}/iiif/auth/v2/token",
      'type' => 'AuthAccessTokenService2',
      'errorHeading' => { 'en' => ['Something went wrong'] },
      'errorNote' => { 'en' => ['Could not get a token.'] }
    )
  end

  def iiif_stacks_v1_login_service
    IIIF::V3::Presentation::Service.new(
      '@context' => 'http://iiif.io/api/auth/1/context.json',
      'id' => "#{Settings.stacks.url}/auth/iiif",
      'profile' => 'http://iiif.io/api/auth/1/login',
      'label' => 'Log in to access all available features.',
      'confirmLabel' => 'Login',
      'failureHeader' => 'Unable to authenticate',
      'failureDescription' => 'The authentication service cannot be reached' \
                              '. If your browser is configured to block pop-up windows, try allow' \
                              'ing pop-up windows for this site before attempting to log in again.',
      'service' => [
        {
          '@id' => "#{Settings.stacks.url}/image/iiif/token",
          'profile' => 'http://iiif.io/api/auth/1/token'
        },
        {
          '@id' => "#{Settings.stacks.url}/Shibboleth.sso/Logout",
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

  def three_d?
    type == '3d'
  end

  def annotation_page_url(**kwargs)
    controller.url_for([:annotation_page, :iiif3, :purl, { id: druid, **kwargs }])
  end

  def nav_place
    @nav_place ||= begin
      nav_place = IIIF::V3::Presentation::NavPlace.new(coordinate_texts:, base_uri: purl_base_uri)
      nav_place.valid? ? nav_place.build : nil # if coordinates are invalid, do nothing, else return navPlace element
    end
  end

  def coordinate_texts
    @coordinate_texts ||= public_xml_document.xpath('//mods:subject/mods:cartographics/mods:coordinates',
                                                    'mods' => IiifPresentationManifest::MODS_SCHEMA).map(&:text)
  end

  def iiif_manifest_class
    if collection?
      IIIF::V3::Presentation::Collection
    else
      IIIF::V3::Presentation::Manifest
    end
  end
end
