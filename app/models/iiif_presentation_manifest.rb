require 'iiif/presentation'

class IiifPresentationManifest
  delegate :druid, :title, :type, :copyright, :description, :content_metadata, :public_xml_document, to: :purl_resource
  delegate :deliverable_files, to: :content_metadata

  attr_reader :purl_resource

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
    @page_images ||= deliverable_files.select do |file|
      file.mimetype == 'image/jp2' && (file.type == 'image' || file.type == 'page') && file.height > 0 && file.width > 0 && deliverable_file?(file)
    end
  end

  def deliverable_file?(file)
    purl_resource.rights.stanford_only_rights_for_file(file.filename) ||
      purl_resource.rights.world_rights_for_file(file.filename)
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

    metadata = []
    # make into method, pass in xpath and label
    metadata += get_metadata 'Creator', '//oai_dc:dc/dc:creator'
    metadata += get_metadata 'Contributor', '//oai_dc:dc/dc:contributor'
    metadata += get_metadata 'Publisher', '//oai_dc:dc/dc:publisher'
    metadata += get_metadata 'Date', '//oai_dc:dc/dc:date'
    metadata += get_metadata 'PublishVersion', '/publicObject/@publishVersion'

    manifest.metadata = metadata if metadata.present?

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

  def canvas(controller: nil, resource_id:)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    resource = page_images.find { |image| image.id == resource_id }

    canvas_for_resource(purl_base_uri, resource)
  end

  def annotation(controller: nil, annotation_id:)
    controller ||= Rails.application.routes.url_helpers
    purl_base_uri = controller.purl_url(druid)

    resource = page_images.find { |image| image.id == annotation_id }

    annotation_for_resource(purl_base_uri, resource)
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
          'profile' => 'http://iiif.io/api/auth/0/login',
          'label' => 'Stanford-affiliated? Login to view',
          'service' => [{
            '@id' => "#{Settings.stacks.url}/image/iiif/token",
            'profile' => 'http://iiif.io/api/auth/0/token'
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

  def get_metadata(label, xpath)
    nodes = public_xml_document.xpath xpath, 'dc' => 'http://purl.org/dc/elements/1.1/', 'oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    nodes.map do |node|
      {
        'label' => label,
        'value' => node.text
      }
    end
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
