require 'iiif/presentation'

class IiifPresentationManifest
  delegate :druid, :title, :type, :copyright, :description, :content_metadata, :public_xml_document, to: :purl_resource
  delegate :reading_order, :resources, to: :content_metadata

  attr_reader :purl_resource

  OAI_DC_SCHEMA = 'http://www.openarchives.org/OAI/2.0/oai_dc/'.freeze

  VIEWING_DIRECTION = {
    'ltr' => 'left-to-right',
    'rtl' => 'right-to-left'
  }.freeze

  def initialize(purl_resource)
    @purl_resource = purl_resource
  end

  def needed?
    if public_xml_document.at_xpath('/publicObject/contentMetadata[contains(@type,"image")
                                                                    or contains(@type,"map")
                                                                    or contains(@type,"book")]/resource[@type="image"]')
      true
    elsif public_xml_document.at_xpath('/publicObject/contentMetadata[@type="book"]/resource[@type="page"]')
      true
    else
      false
    end
  end

  def page_images
    @page_images ||= resources.select do |file|
      image?(file) && deliverable_file?(file)
    end
  end

  def image?(file)
    file.mimetype == 'image/jp2' && (file.type == 'image' || file.type == 'page') && file.height > 0 && file.width > 0
  end

  # also is this right?  should it handle location rights too?
  def deliverable_file?(file)
    purl_resource.rights.stanford_only_rights_for_file(file.filename).first ||
      purl_resource.rights.world_rights_for_file(file.filename).first
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
  def body(controller = nil)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    manifest_data = {
      '@id'   => controller.iiif_manifest_url(druid),
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
    order = reading_order

    sequence = IIIF::Presentation::Sequence.new(
      '@id' => "#{purl_base_uri}#sequence-1",
      'label' => 'Current order'
    )

    sequence.viewingDirection = VIEWING_DIRECTION[order] if order

    manifest.thumbnail = thumbnail_resource

    # for each resource image, create a canvas
    page_images.each do |resource|
      sequence.canvases << canvas_for_resource(purl_base_uri, resource)
    end

    manifest.sequences << sequence
    manifest
  end

  def canvas(controller: nil, resource_id:)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    resource = page_images.find { |image| image.id == resource_id }

    canvas_for_resource(purl_base_uri, resource) if resource
  end

  def annotation(controller: nil, annotation_id:)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    resource = page_images.find { |image| image.id == annotation_id }

    annotation_for_resource(purl_base_uri, resource) if resource
  end

  def canvas_for_resource(purl_base_uri, resource)
    canv = IIIF::Presentation::Canvas.new
    canv['@id'] = "#{purl_base_uri}/iiif/canvas/#{resource.id}"
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
    anno['@id'] = "#{purl_base_uri}/iiif/annotation/#{resource.id}"

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

  def iiif_service(id)
    IIIF::Service.new(
      '@context' => 'http://iiif.io/api/image/2/context.json',
      '@id' => id,
      'profile' => Settings.stacks.iiif_profile
    )
  end

  # transform all DC metadata in the public XML into an array of hashes for inclusion in the IIIF manifest
  def dc_to_iiif_metadata
    @dc_to_iiif_metadata ||= begin
      all_dc_nodes = public_xml_document.xpath '//oai_dc:dc/*', 'oai_dc' => OAI_DC_SCHEMA
      metadata = all_dc_nodes.map { |dc_node| iiif_key_value(dc_node.name.upcase_first, dc_node.text) }
      metadata += public_xml_document.xpath('/publicObject/@published').map { |node| iiif_key_value('PublishDate', node.text) } # add published date
      metadata
    end
  end

  def iiif_key_value(label, value)
    { 'label' => label, 'value' => value }
  end

  def thumbnail_resource
    return unless thumbnail_image

    thumb = IIIF::Presentation::ImageResource.new
    thumb['@id'] = "#{thumbnail_base_uri}/full/!400,400/0/default.jpg"
    thumb.format = 'image/jpeg'
    thumb.service = iiif_service(thumbnail_base_uri)

    thumb
  end

  # If not available, use the first image to create a thumbnail on the manifest
  def thumbnail_image
    @thumbnail_image ||= page_images.detect(&:thumbnail?) || page_images.first
  end

  def thumbnail_base_uri
    @thumbnail_base_uri ||= begin
      stacks_iiif_base_url(thumbnail_image.druid, thumbnail_image.filename) if thumbnail_image
    end
  end

  def stacks_iiif_base_url(druid, filename)
    "#{Settings.stacks.url}/image/iiif/#{druid}%2F#{File.basename(filename, '.*')}"
  end
end
