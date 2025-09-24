# frozen_string_literal: true

require 'iiif/presentation'
require 'iiif/v3/presentation'

class Iiif3PresentationManifest < IiifPresentationManifest
  delegate :object?, :geo?, :image?, :map?, :three_d?, to: :item_type

  delegate :file_sets, to: :structural_metadata
  attr_reader :purl_base_uri

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def body
    manifest_data = {
      '@context' => IIIF::V3::Presentation::CONTEXT,
      'id' => manifest_url,
      'label' => { 'en' => [display_title] },
      'requiredStatement' => {
        'label' => { 'en' => ['Attribution'] },
        'value' => { 'en' => attribution.compact_blank }
      },
      'provider' => [provider],
      'seeAlso' => [{
        'id' => controller.purl_url(druid, format: 'mods'),
        'type' => 'Metadata',
        'format' => 'application/mods+xml'
      }]
    }

    manifest_data['service'] = [content_search_service] if content_search_service

    manifest = iiif_manifest_class.new(manifest_data)

    # Set behavior to paged if this is a book
    manifest['behavior'] = ['paged'] if book?
    (_collection, collection_head_version) = containing_purl_collections&.first
    collection_title = collection_head_version&.display_title
    metadata_writer = Iiif3MetadataWriter.new(cocina_display: purl_version.cocina_display,
                                              published_date: updated_at,
                                              collection_title:)
    manifest.metadata = metadata_writer.write

    if nav_place
      manifest['navPlace'] = nav_place
      manifest['@context'] += ['http://iiif.io/api/extension/navplace/context.json']
    end

    manifest.summary = { 'en' => [description_or_note] } if description_or_note.present?

    manifest.viewingDirection = purl_version.structural_metadata.viewing_direction || 'left-to-right'

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

  def annotation(annotation_id:)
    fileset = page_image_filesets.find { |fileset| fileset.cocina_id == annotation_id }
    annotation_for_file(fileset.primary) if fileset
  end

  def build_canvases(manifest)
    # for each resource sequence (SDR term), create a canvas
    if object? || geo?
      # Geo can't determine "primary", so we just create a "dummy" canvas here.
      # We don't use the canvases for the file viewer and it slows down the metadata viewer when there are a lot of files
      # IIIF v3 requires Manifests to have at least one canvas. https://iiif.io/api/presentation/3.0/#34-structural-properties
      fileset = file_sets.first
      manifest.items << canvas_for_fileset(fileset, file: fileset.files.first)
    elsif book? || image? || map?
      build_image_canvases(manifest)
    else
      build_non_image_canvases(manifest)
    end

    add_virtual_object_canvases(manifest)
  end

  def build_non_image_canvases(manifest)
    file_sets.each do |fs|
      # Sul-embed expects only the files with type 3d for the manifest
      # model-viewer only supports glTF/GLB 3D models (in cocina type == 3d)
      next if three_d? && fs.type != 'https://cocina.sul.stanford.edu/models/resources/3d'

      canvas = canvas_for_fileset(fs)
      manifest.items << canvas if canvas
    end
  end

  # Cocina only lists druids for collection objects, not filesets
  # We need to go grab the PurlResource for the druid
  # It seems like we are only doing this for type images. I am not sure why
  def add_virtual_object_canvases(manifest)
    # For each valid virtual object image, create a canvas for its thumbnail
    structural_metadata.members&.each do |member_druid|
      purl_version = PurlResource.find(member_druid.delete_prefix('druid:')).version(:head)
      # We are using .thumbail here to get the first image in the object
      thumbnail_fs = purl_version.thumbnail_service.thumb_fs
      # Overwrite default label for virtual objects
      thumbnail_fs.files.first.fileset_label = purl_version.cocina['label']
      manifest.items << canvas_for_fileset(thumbnail_fs)
    rescue ResourceRetriever::ResourceNotFound
      Honeybadger.notify('Error occurred retrieving virtual object', context: { druid: member_druid })
    end
  end

  def build_image_canvases(manifest)
    file_sets.each do |fs|
      file = fs.primary || fs.files.first

      if file.image_file? && fs.page_image?
        manifest.items << canvas_for_fileset(fs) if deliverable_file?(file)
      elsif downloadable_file?(file)
        manifest.rendering += image_rendering_for_fileset(fs)
      end
    end
  end

  def attribution
    [copyright || 'Provided by the Stanford University Libraries'].flatten
  end

  def annotation_page(fileset_id:)
    selected_resource = file_sets.find { |fileset| fileset.cocina_id == fileset_id }
    annotation_page_for_file(selected_resource.primary) if selected_resource
  end

  def canvas_for_fileset(fileset, file: fileset.primary)
    return unless file

    canv = IIIF::V3::Presentation::Canvas.new
    canv['id'] = canvas_url(resource_id: file.fileset_id)
    canv.label = {
      'en' => [file.fileset_label.presence || 'image']
    }
    canv.rendering = []

    if file.image_file?
      canv.height = file.height
      canv.width = file.width
      if downloadable_file?(file)
        canv.rendering += [binary_resource(
          file,
          label: "Original source file (#{number_to_human_size(file.size)})"
        ).to_ordered_hash]
      end
    end
    canv.items << annotation_page_for_file(file)

    if fileset.files.any?
      thumbnail_canvas = thumbnail_canvas_for_file_group(fileset)
      canvas_type = fileset.audio? ? 'accompanyingCanvas' : 'placeholderCanvas'
      canv[canvas_type] = thumbnail_canvas

      canv['annotations'] = [{ id: annotation_list_url(resource_id: fileset.cocina_id), type: 'AnnotationPage' }] if image_annotations(fileset).present?

      canv['annotations'] = caption_annotations(fileset) if fileset.media?

      canv.rendering += renderings_for_fileset(fileset)
    end

    canv
  end

  def thumbnail_canvas_for_file_group(fileset)
    return unless fileset.media_file && thumbnail_image

    thumbnail_canvas = IIIF::V3::Presentation::Canvas.new
    thumbnail_canvas['id'] = canvas_url(resource_id: thumbnail_image.filename)
    thumbnail_canvas.label = { 'en' => [thumbnail_image.label.presence || 'image'] }

    if thumbnail_image.image_file?
      thumbnail_canvas.height = thumbnail_image.height
      thumbnail_canvas.width = thumbnail_image.width
    end

    thumbnail_canvas.items << annotation_page_for_file(thumbnail_image)
    thumbnail_canvas
  end

  def caption_annotations(fileset)
    return unless fileset.supplementing_resources.any?

    annotation_page = IIIF::V3::Presentation::AnnotationPage.new
    annotation_page['id'] = "#{annotation_page_url(resource_id: fileset.primary.id)}/supplement"

    fileset.supplementing_resources.each do |supplementing_resource|
      anno = annotation_for_file(supplementing_resource)
      anno.id = annotation_url(resource_id: supplementing_resource.filename)
      anno.motivation = 'supplementing'
      annotation_page.items << anno
    end

    [annotation_page]
  end

  def renderings_for_fileset(fileset)
    fileset.other_resources.filter_map do |other_resource|
      binary_resource(other_resource).to_ordered_hash if downloadable_file?(other_resource)
    end
  end

  def image_rendering_for_fileset(fileset)
    fileset.files.map do |file|
      binary_resource(file).to_ordered_hash
    end
  end

  def annotation_page_for_file(file)
    anno_page = IIIF::V3::Presentation::AnnotationPage.new
    anno_page['id'] = annotation_page_url(resource_id: file.fileset_id)
    anno_page.items << annotation_for_file(file)
    anno_page
  end

  def annotation_for_file(file)
    anno = IIIF::V3::Presentation::Annotation.new
    anno['id'] = annotation_url(resource_id: file.fileset_id)
    anno['target'] = canvas_url(resource_id: file.fileset_id)

    anno.body = if file.image_file?
                  image_resource(file)
                else
                  binary_resource(file)
                end

    anno
  end

  def annotation_list(resource_id:)
    fileset = file_sets.find { |fileset| fileset.cocina_id == resource_id }

    return if fileset.blank?

    anno_list = IIIF::V3::Presentation::AnnotationPage.new
    anno_list['id'] = annotation_list_url(resource_id:)

    anno_list.items = []

    image_annotations(fileset).each do |file|
      annotation = annotation_for_file(file)
      annotation.body = JSON.parse(
        Faraday.get(
          stacks_file_url(druid, file.filename)
        ).body
      )
      anno_list.items << annotation
    end
    anno_list
  end

  def image_annotations(fileset)
    return [] unless fileset.files

    fileset.files.select { |file| file.role == 'annotations' && file.mimetype == 'application/json' }
  end

  def image_resource(file)
    url = stacks_iiif_base_url(file.druid, file.filename)

    img_res = IIIF::V3::Presentation::ImageResource.new
    img_res['id'] = "#{url}/full/full/0/default.jpg"
    img_res.format = 'image/jpeg'
    img_res.height = file.height
    img_res.width = file.width

    img_res.service = [iiif_image_v2_service(url)]
    img_res.service[0]['services'] = case file.access.view
                                     when 'stanford'
                                       [iiif_stacks_v1_login_service]
                                     when 'location-based'
                                       [iiif_location_auth_service]
                                     else
                                       []
                                     end

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
    bin_res['label'] = { 'en' => [label] }
    bin_res.format = resource.mimetype

    bin_res.service = [probe_service(resource, file_url)]

    bin_res
  end

  def probe_service(file, file_url)
    IIIF::V3::Presentation::Service.new(
      'id' => "#{Settings.stacks.url}/iiif/auth/v2/probe?id=#{URI.encode_uri_component(file_url)}",
      'type' => 'AuthProbeService2',
      'errorHeading' => { 'en' => ['No access'] },
      'errorNote' => { 'en' => ['You do not have permission to access this resource'] }
    ).tap do |probe_service|
      probe_service.service = case file.access.view
                              when 'world'
                                # We only need this because a probe service MUST have one or more access services and
                                # we want to run the probe service so that it can redirect to the streaming server.
                                # See https://iiif.io/api/auth/2.0/#probe-service-description
                                [iiif_v2_access_service_external_public]
                              when 'location-based'
                                [iiif_v2_location_restricted]
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
    thumb['id'] = purl_version.representative_thumbnail
    thumb.format = 'image/jpeg'
    thumb.service = [iiif_image_v2_service(purl_version.thumbnail_base_uri)]
    thumb.height = thumbnail_image.thumbnail_height
    thumb.width = thumbnail_image.thumbnail_width
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

  def iiif_v2_location_restricted
    IIIF::V3::Presentation::Service.new(
      'id' => "#{Settings.stacks.url}/auth/iiif",
      'type' => 'AuthAccessService2',
      'profile' => 'active',
      'label' => { 'en' => ['Restricted content cannot be accessed from your location'] },
      'confirmLabel' => { 'en' => ['Restricted content cannot be accessed from your location'] }
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

  def annotation_page_url(**kwargs)
    controller.url_for([:annotation_page, :iiif3, :purl, { id: druid, **kwargs }])
  end

  def nav_place
    @nav_place ||= begin
      nav_place = IIIF::V3::Presentation::NavPlace.new(coordinate_texts: purl_version.cocina_display.coordinates, base_uri: purl_base_uri)
      nav_place.valid? ? nav_place.build : nil # if coordinates are invalid, do nothing, else return navPlace element
    end
  end

  def iiif_manifest_class
    if collection?
      IIIF::V3::Presentation::Collection
    else
      IIIF::V3::Presentation::Manifest
    end
  end
end
