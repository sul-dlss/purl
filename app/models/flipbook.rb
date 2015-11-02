class Flipbook
  delegate :druid, :title, to: :purl_resource
  attr_reader :purl_resource

  def initialize(purl_resource)
    @purl_resource = purl_resource
  end

  def to_json
    @json ||= {
      id: catalog_key.to_s,
      readGroup: read_group,
      objectId: druid.to_s,
      defaultViewMode: 2,
      bookTitle: title,
      readingOrder: reading_order, # "rtl"
      pageStart: page_start, # "left"
      bookURL: catalog_key? ? "http://searchworks.stanford.edu/view/#{catalog_key}" : '',
      pages: pages
    }
  end

  def page_images
    deliverable_files.select do |file|
      file.mimetype == 'image/jp2' && (file.type == 'image' || file.type == 'page') && file.height > 0 && file.width > 0 && (deliverable_file?(file))
    end
  end

  def deliverable_file?(file)
    purl_resource.rights.stanford_only_rights_for_file(file.filename) ||
      purl_resource.rights.world_rights_for_file(file.filename)
  end

  def pages
    page_images.map do |file|
      {
        height: file.height,
        width: file.width,
        levels: file.levels,
        resourceType: file.type,
        label: file.label,
        stacksURL: stacks_iiif_url(druid, file.filename)
      }
    end
  end

  def catalog_key?
    catalog_key.present?
  end

  def stacks_iiif_url(druid, filename)
    "#{Settings.stacks.url}/image/iiif/#{druid}%2F#{File.basename(filename, '.*')}/full/full/0/default.jpg"
  end

  delegate :catalog_key, :content_metadata, :rights, to: :purl_resource
  delegate :reading_order, :page_start, :deliverable_files, to: :content_metadata
  delegate :read_group, to: :rights
end
