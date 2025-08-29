# frozen_string_literal: true

require 'iiif/presentation'

class IiifPresentationManifest
  include ActiveModel::Model

  delegate :druid, :display_title, :book?, :structural_metadata, :public_xml_document, :cocina, :updated_at, :containing_purl_collections,
           :collection?, to: :purl_version
  delegate :url_for, to: :controller
  delegate :file_sets, :local_files, to: :structural_metadata
  alias id druid

  attr_reader :purl_version, :controller, :iiif_namespace

  include ActionView::Helpers::NumberHelper

  OAI_DC_SCHEMA = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
  MODS_SCHEMA = 'http://www.loc.gov/mods/v3'

  def initialize(purl_version, iiif_namespace: :iiif, controller: nil)
    @purl_version = purl_version
    @iiif_namespace = iiif_namespace
    @controller = controller
  end

  # @return [Array<StructuralMetadata::FileSet>] or []
  def page_image_filesets
    @page_image_filesets ||= file_sets.select(&:page_image?)
  end

  # @return [Array<StructuralMetadata::File>] or []
  def page_image_files
    page_image_filesets.flat_map(&:files).select { |file| file.image_file? && deliverable_file?(file) }
  end

  # @return [Array<StructuralMetadata::File>] or []
  def object_files
    @object_files ||= local_files.select do |file|
      object_file?(file) && downloadable_file?(file)
    end
  end

  # @return [Array<StructuralMetadata::File>] or []
  def ocr_files
    @ocr_files ||= local_files.select do |file|
      download_access = file.access.download
      file.role == 'transcription' && download_access == 'world'
    end
  end

  def ocr_text?
    ocr_files.present?
  end

  def object_file?(file)
    file.type == 'https://cocina.sul.stanford.edu/models/file'
  end

  # @param [StructuralMetadata::File]
  def deliverable_file?(file)
    %w[world stanford location-based].include?(file.access.view) || structural_metadata.thumbnail == file
  end

  # @param [StructuralMetadata::File]
  def downloadable_file?(file)
    %w[world stanford].include? file.access.download
  end

  def description_or_note
    @description_or_note ||= begin
      ns = {
        'dc' => 'http://purl.org/dc/elements/1.1/',
        'oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/'
      }

      public_xml_document.at_xpath('//oai_dc:dc/dc:description', ns).try(:text)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def body
    manifest_data = {
      '@id' => manifest_url,
      'label' => display_title,
      'attribution' => copyright || 'Provided by the Stanford University Libraries',
      'logo' => {
        '@id' => 'https://stacks.stanford.edu/image/iiif/wy534zh7137/SULAIR_rosette/full/400,/0/default.jpg',
        'service' => iiif_service('https://stacks.stanford.edu/image/iiif/wy534zh7137/SULAIR_rosette')
      },
      'seeAlso' => {
        '@id' => controller.purl_url(druid, format: 'mods'),
        'format' => 'application/mods+xml'
      }
    }

    manifest = IIIF::Presentation::Manifest.new manifest_data
    manifest.service << content_search_service if content_search_service

    # Set viewingHint to paged if this is a book
    manifest.viewingHint = 'paged' if book?

    manifest.metadata = dc_to_iiif_metadata if dc_to_iiif_metadata.present?
    manifest.metadata.unshift(
      'label' => 'Available Online',
      'value' => "<a href='#{controller.purl_url(druid)}'>#{controller.purl_url(druid)}</a>"
    )

    manifest.description = description_or_note

    sequence = IIIF::Presentation::Sequence.new(
      '@id' => "#{manifest_url}#sequence-1",
      'label' => 'Current order'
    )

    sequence.viewingDirection = purl_version.structural_metadata.viewing_direction || 'left-to-right'

    manifest.thumbnail = thumbnail_resource

    renderings = object_files.map do |file|
      rendering_file(file)
    end

    sequence['rendering'] = renderings if renderings.present?

    # For each local file image, create a canvas
    page_image_files.each do |file|
      sequence.canvases << canvas_for_file(file)
    end

    # For each valid virtual object image, create a canvas for its thumbnail
    # TODO: extract to fix final failing test
    structural_metadata.virtual_object_members&.each do |member_druid|
      purl_version = PurlResource.find(member_druid.delete_prefix('druid:')).version(:head)
      # We are using .thumbail here to get the first image in the object
      thumbnail_file = purl_version.structural_metadata.thumbnail
      # Overwrite default label for virtual objects
      thumbnail_file.fileset_label = purl_version.cocina['label']
      sequence.canvases << canvas_for_file(thumbnail_file)
    rescue ResourceRetriever::ResourceNotFound
      Honeybadger.notify('Error occurred retrieving virtual object', context: { druid: member_druid })
    end

    manifest.sequences << sequence
    manifest
  end

  # @return [IIIF::Presentation::Canvas] or nil
  def canvas(fileset_id:)
    file = page_image_files.find { |image| image.id == fileset_id }
    canvas_for_file(file) if file
  end

  ##
  # Creates an annotationList
  # @return [Array<IIIF::Presentation::AnnotationList>] or nil
  def annotation_list(fileset_id:)
    return unless local_files.any?

    anno_list = IIIF::Presentation::AnnotationList.new
    anno_list['@id'] = annotation_list_url(resource_id: fileset_id)
    anno_list.resources = []
    local_files.select { |file| file.role == 'annotations' && file.mimetype == 'application/json' }.each do |file|
      anno_list.resources << JSON.parse(
        Faraday.get(
          stacks_file_url(druid, file.filename)
        ).body
      )
    end
    anno_list
  end

  def annotation(annotation_id:)
    file = page_image_files.find { |image| image.id == annotation_id }

    annotation_for_file(file) if file
  end

  def canvas_for_file(file)
    canv = IIIF::Presentation::Canvas.new
    canv['@id'] = canvas_url(resource_id: file.fileset_id)
    canv.label = file.fileset_label
    canv.label = 'image' if canv.label.blank?
    canv.height = file.height
    canv.width = file.width
    if downloadable_file?(file)
      canv['rendering'] = [
        rendering_file(
          file,
          label: "Original source file (#{number_to_human_size(file.size)})"
        )
      ]
    end

    ocr_file = ocr_files.select do |f|
      f.fileset_id == file.fileset_id
    end

    canv['seeAlso'] = ocr_file.map do |f|
      # Profile for Alto resources. We don't yet really have HOCR transcriptions published as role="transcription"
      rendering_file(f, label: 'OCR text', profile: 'http://www.loc.gov/standards/alto/ns-v2#')
    end

    other_content = other_content_for_file(file)
    canv.otherContent = other_content if other_content.present?

    anno = annotation_for_file(file)
    anno['on'] = canv['@id']
    canv.images << anno
    canv
  end

  # Setup annotationLists for files with role="annotations"
  def other_content_for_file(file)
    return unless local_files.any?

    other_content = []

    if local_files.any? { |file| file.role == 'annotations' && file.mimetype == 'application/json' }
      anno_list = IIIF::Presentation::AnnotationList.new
      anno_list['@id'] = annotation_list_url(resource_id: file.fileset_id)
      other_content << anno_list
    end

    other_content
  end

  # @param [StructuralMetadata::File]
  def annotation_for_file(file)
    url = stacks_iiif_base_url(file.druid, file.filename)

    anno = IIIF::Presentation::Annotation.new
    anno['@id'] = annotation_url(resource_id: file.id)

    img_res = IIIF::Presentation::ImageResource.new
    img_res['@id'] = "#{url}/full/full/0/default.jpg"
    img_res.format = 'image/jpeg'
    img_res.height = file.height
    img_res.width = file.width

    img_res.service = iiif_service(url)

    img_res.service['service'] = case file.access.view
                                 when 'stanford'
                                   img_res.service['service'] = [iiif_stacks_login_service]
                                 when 'location-based'
                                   img_res.service['service'] = [iiif_location_auth_service]
                                 else
                                   []
                                 end

    anno.resource = img_res
    anno
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def iiif_service(id)
    IIIF::Service.new(
      '@context' => 'http://iiif.io/api/image/2/context.json',
      '@id' => id,
      'profile' => Settings.stacks.iiif_profile
    )
  end

  def content_search_service
    return nil unless Settings.content_search.url && ocr_text?

    {
      '@context' => 'http://iiif.io/api/search/1/context.json',
      '@id' => format(Settings.content_search.url, druid:),
      'profile' => 'http://iiif.io/api/search/1/search',
      'label' => 'Search within this manifest'
    }
  end

  # transform all DC metadata in the public XML into an array of hashes for inclusion in the IIIF manifest
  def dc_to_iiif_metadata
    @dc_to_iiif_metadata ||= begin
      all_dc_nodes = public_xml_document.xpath '//oai_dc:dc/*', 'oai_dc' => OAI_DC_SCHEMA
      metadata = all_dc_nodes.filter_map { |dc_node| iiif_key_value(dc_node.name.upcase_first, dc_node.text) }
      metadata += public_xml_document.xpath('/publicObject/@published').map { |node| iiif_key_value('PublishDate', node.text) } # add published date
      metadata
    end
  end

  def iiif_key_value(label, value)
    return if value.blank?

    { 'label' => label, 'value' => value }
  end

  # rubocop:disable Metrics/AbcSize
  # @return [IIIF::Presentation::ImageResource] or nil
  def thumbnail_resource
    return unless thumbnail_image

    thumb = IIIF::Presentation::ImageResource.new
    thumb['@id'] = "#{thumbnail_base_uri}/full/!400,400/0/default.jpg"
    thumb.format = 'image/jpeg'
    thumb.service = iiif_service(thumbnail_base_uri)
    if thumbnail_image.height >= thumbnail_image.width
      thumb.height = 400
      thumb.width = ((400.0 * thumbnail_image.width) / thumbnail_image.height).round
    else
      thumb.width = 400
      thumb.height = ((400.0 * thumbnail_image.height) / thumbnail_image.width).round
    end

    thumb
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

  def local_thumbnail_image
    page_image_files.first
  end

  def thumbnail_image
    @thumbnail_image ||= local_thumbnail_image || structural_metadata.virtual_object_thumbnail
  end

  def rendering_file(file, label: "Download #{file.label}", profile: nil)
    {
      '@id' => stacks_file_url(file.druid, file.filename),
      'label' => label,
      'format' => file.mimetype,
      'profile' => profile
    }.compact
  end

  def thumbnail_base_uri
    @thumbnail_base_uri ||= (stacks_iiif_base_url(thumbnail_image.druid, thumbnail_image.filename) if thumbnail_image)
  end

  def stacks_iiif_base_url(druid, filename)
    "#{Settings.stacks.url}/image/iiif/#{druid}%2F#{ERB::Util.url_encode(File.basename(filename, '.*'))}"
  end

  def stacks_file_url(druid, filename)
    "#{Settings.stacks.url}/file/#{druid}/#{ERB::Util.url_encode(filename)}"
  end

  def iiif_stacks_login_service
    IIIF::Service.new(
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
    IIIF::Service.new(
      '@context' => 'http://iiif.io/api/auth/1/context.json',
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

  delegate :copyright, to: :purl_version

  def manifest_url(**kwargs)
    controller.url_for([:manifest, iiif_namespace, :purl, { id: druid, **kwargs }])
  end

  def canvas_url(**kwargs)
    controller.url_for([:canvas, iiif_namespace, :purl, { id: druid, **kwargs }])
  end

  def annotation_list_url(**kwargs)
    controller.url_for([:annotation_list, iiif_namespace, :purl, { id: druid, **kwargs }])
  end

  def annotation_url(**kwargs)
    controller.url_for([:annotation, iiif_namespace, :purl, { id: druid, **kwargs }])
  end
end
