# frozen_string_literal: true

require 'iiif/presentation'

class IiifPresentationManifest
  include ActiveModel::Model

  delegate :druid, :title, :type, :description, :content_metadata, :public_xml_document, :cocina, :updated_at,
           :containing_purl_collections, :rights, :collection?, to: :purl_version
  delegate :reading_order, :resources, to: :content_metadata
  delegate :url_for, to: :controller
  alias id druid

  attr_reader :purl_version, :controller, :iiif_namespace

  include ActionView::Helpers::NumberHelper

  OAI_DC_SCHEMA = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
  MODS_SCHEMA = 'http://www.loc.gov/mods/v3'

  VIEWING_DIRECTION = {
    'ltr' => 'left-to-right',
    'rtl' => 'right-to-left'
  }.freeze

  def initialize(purl_version, iiif_namespace: :iiif, controller: nil)
    @purl_version = purl_version
    @iiif_namespace = iiif_namespace
    @controller = controller
  end

  def page_images
    @page_images ||= resources.select do |file|
      image?(file) && %w[image page].include?(file.type) && deliverable_file?(file)
    end
  end

  def object_files
    @object_files ||= resources.select do |file|
      object?(file) && downloadable_file?(file)
    end
  end

  def ocr_files
    @ocr_files ||= resources.select do |file|
      world_visible, world_rule = rights.world_rights_for_file(file.filename)
      file.role == 'transcription' &&
        world_visible &&
        world_rule != 'no-download'
    end
  end

  def grouped_resource_by_id(id)
    content_metadata.grouped_resources.find { |grouped_resource| grouped_resource.id == id }
  end

  def object?(file)
    file.type == 'object'
  end

  def image?(file)
    file.mimetype == 'image/jp2' && file.height.positive? && file.width.positive?
  end

  def deliverable_file?(file)
    rights.stanford_only_rights_for_file(file.filename).first ||
      rights.world_rights_for_file(file.filename).first ||
      rights.restricted_by_location?(file.filename) ||
      rights.cdl_rights_for_file(file.filename) ||
      thumbnail?(file)
  end

  def downloadable_file?(file)
    rights.world_downloadable_file?(file) ||
      rights.stanford_only_downloadable_file?(file)
  end

  def ocr_text?
    ocr_files.present?
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

  # Bypass this method if there are no image resources in contentMetadata
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def body
    manifest_data = {
      '@id' => manifest_url,
      'label' => title,
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
    manifest.viewingHint = 'paged' if type == 'book'

    manifest.metadata = dc_to_iiif_metadata if dc_to_iiif_metadata.present?
    manifest.metadata.unshift(
      'label' => 'Available Online',
      'value' => "<a href='#{controller.purl_url(druid)}'>#{controller.purl_url(druid)}</a>"
    )

    manifest.description = description_or_note
    order = reading_order

    sequence = IIIF::Presentation::Sequence.new(
      '@id' => "#{manifest_url}#sequence-1",
      'label' => 'Current order'
    )

    sequence.viewingDirection = case order
                                when nil
                                  VIEWING_DIRECTION['ltr']
                                else
                                  VIEWING_DIRECTION[order]
                                end

    manifest.thumbnail = thumbnail_resource

    renderings = object_files.map do |resource|
      rendering_resource(resource)
    end

    sequence['rendering'] = renderings if renderings.present?

    # for each resource image, create a canvas
    page_images.each do |resource|
      sequence.canvases << canvas_for_resource(resource)
    end

    manifest.sequences << sequence
    manifest
  end

  def canvas(resource_id:)
    resource = page_images.find { |image| image.id == resource_id }

    canvas_for_resource(resource) if resource
  end

  ##
  # Creates an annotationList
  def annotation_list(resource_id:)
    grouped_resource = grouped_resource_by_id(resource_id)
    return unless grouped_resource

    anno_list = IIIF::Presentation::AnnotationList.new
    anno_list['@id'] = annotation_list_url(resource_id:)
    anno_list.resources = []
    grouped_resource.files.select { |file| file.role == 'annotations' && file.mimetype == 'application/json' }.each do |file|
      anno_list.resources << JSON.parse(
        Faraday.get(
          stacks_file_url(druid, file.filename)
        ).body
      )
    end
    anno_list
  end

  def annotation(annotation_id:)
    resource = page_images.find { |image| image.id == annotation_id }

    annotation_for_resource(resource) if resource
  end

  def canvas_for_resource(resource)
    canv = IIIF::Presentation::Canvas.new
    canv['@id'] = canvas_url(resource_id: resource.id)
    canv.label = resource.label
    canv.label = 'image' unless canv.label.present?
    canv.height = resource.height
    canv.width = resource.width
    if downloadable_file?(resource)
      canv['rendering'] = [
        rendering_resource(
          resource,
          label: "Original source file (#{number_to_human_size(resource.size)})"
        )
      ]
    end
    ocr_file = ocr_files.select { |f| f.id == resource.id }
    canv['seeAlso'] = ocr_file.map do |f|
      # Profile for Alto resources. We don't yet really have HOCR transcriptions published as role="transcription"
      rendering_resource(f, label: 'OCR text', profile: 'http://www.loc.gov/standards/alto/ns-v2#')
    end

    other_content = other_content_for_resource(resource)
    canv.otherContent = other_content if other_content.present?

    anno = annotation_for_resource(resource)
    anno['on'] = canv['@id']
    canv.images << anno
    canv
  end

  # Setup annotationLists for files with role="annotations"
  def other_content_for_resource(resource)
    grouped_resource = grouped_resource_by_id(resource.id)
    return unless grouped_resource

    other_content = []

    if grouped_resource.files.any? { |file| file.role == 'annotations' && file.mimetype == 'application/json' }
      anno_list = IIIF::Presentation::AnnotationList.new
      anno_list['@id'] = annotation_list_url(resource_id: resource.id)
      other_content << anno_list
    end

    other_content
  end

  def annotation_for_resource(resource)
    url = stacks_iiif_base_url(resource.druid, resource.filename)

    anno = IIIF::Presentation::Annotation.new
    anno['@id'] = annotation_url(resource_id: resource.id)

    img_res = IIIF::Presentation::ImageResource.new
    img_res['@id'] = "#{url}/full/full/0/default.jpg"
    img_res.format = 'image/jpeg'
    img_res.height = resource.height
    img_res.width = resource.width

    img_res.service = iiif_service(url)
    img_res.service['service'] = []

    if rights.stanford_only_rights_for_file(resource.filename).first
      img_res.service['service'] = [iiif_stacks_login_service]
    end

    if rights.cdl_rights_for_file(resource.filename)
      img_res.service['service'] = [iiif_cdl_login_service]
    end

    if rights.restricted_by_location?(resource.filename)
      img_res.service['service'].append(iiif_location_auth_service)
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
  # rubocop:enable Metrics/AbcSize

  def rendering_resource(resource, label: "Download #{resource.label}", profile: nil)
    {
      '@id' => stacks_file_url(resource.druid, resource.filename),
      'label' => label,
      'format' => resource.mimetype,
      'profile' => profile
    }.compact
  end

  # If not available, use the first image to create a thumbnail on the manifest
  def thumbnail_image
    @thumbnail_image ||= page_images.detect { |file| thumbnail?(file) } || page_images.first
  end

  def thumbnail_base_uri
    @thumbnail_base_uri ||= begin
      stacks_iiif_base_url(thumbnail_image.druid, thumbnail_image.filename) if thumbnail_image
    end
  end

  def thumbnail?(file)
    purl_version.public_xml.thumb == "#{file.druid}/#{file.filename}"
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

  def iiif_cdl_login_service
    IIIF::Service.new(
      '@context' => 'http://iiif.io/api/auth/1/context.json',
      'id' => "#{Settings.stacks.url}/auth/iiif/cdl/#{druid}/checkout",
      'profile' => 'http://iiif.io/api/auth/1/login',
      'label' => 'Available for checkout.',
      'confirmLabel' => 'Checkout',
      'failureHeader' => 'Unable to authenticate',
      'failureDescription' => 'The authentication service cannot be reached.',
      'service' => [
        {
          '@id' => "#{Settings.stacks.url}/image/iiif/token/#{druid}",
          'profile' => 'http://iiif.io/api/auth/1/token'
        },
        {
          '@id' => "#{Settings.stacks.url}/auth/iiif/cdl/#{druid}/checkin",
          'profile' => 'http://iiif.io/api/auth/1/logout',
          'label' => 'Check in early'
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

  def copyright
    if rights.controlled_digital_lending?
      return [
        cdl_copyright_statement,
        purl_version.copyright.presence
      ].compact
    end

    purl_version.copyright
  end

  # rubocop:disable Rails/OutputSafety, Metrics/MethodLength
  def cdl_copyright_statement
    <<-EOSTATEMENT.html_safe
      <p>
        This Item may be protected by third-party copyright and/or related intellectual property rights. It is provided by Stanford University Libraries on a non-commercial basis for your personal academic and educational research purposes only. You may not make copies of the Item, display it online (e.g., on the internet), or distribute it to anyone else, including friends, colleagues, or classmates. By continuing to use this digital resource you are acknowledging and agree to comply with these terms of use. For additional details, see the following Copyright Notice.
      </p>
      <p>
        NOTICE WARNING CONCERNING COPYRIGHT RESTRICTIONS
      </p>
      <p>
        The copyright law of the United States (title 17, United States Code) governs
        the making of photocopies or other reproductions of copyrighted material.
      </p>
      <p>
        Under certain conditions specified in the law, libraries and archives are
        authorized to furnish a photocopy or other reproduction. One of these
        specific conditions is that the photocopy or reproduction is not to be
        “used for any purpose other than private study, scholarship, or research.”
        If a user makes a request for, or later uses, a photocopy or reproduction
        for purposes in excess of “fair use,” that user may be liable for copyright infringement.
      </p>
      <p>
        This institution reserves the right to refuse to accept a copying order
        if, in its judgment, fulfillment of the order would involve violation
        of copyright law.
      </p>
    EOSTATEMENT
  end
  # rubocop:enable Rails/OutputSafety, Metrics/MethodLength

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
