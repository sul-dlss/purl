class PublicXml
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def title
    @title ||= document.root.at_xpath('oai_dc:dc/dc:title', oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/', dc: 'http://purl.org/dc/elements/1.1/')&.text
  end

  def rights_metadata
    document.root.at_xpath('rightsMetadata')
  end

  def content_metadata
    document.root.at_xpath('contentMetadata')
  end

  def catalog_key
    @catalog_key ||= document.root.at_xpath('identityMetadata/otherId[@name="catkey"]')&.text.presence
    @catalog_key ||= begin
      key = folio_instance_hrid
      key = key.delete_prefix('a') if key&.match?(/^a\d+$/)
      key
    end
  end

  def folio_instance_hrid
    @folio_instance_hrid ||= document.root.at_xpath('identityMetadata/otherId[@name="folio_instance_hrid"]')&.text.presence
  end

  def released_to?(key)
    release = document.root.at_xpath("releaseData/release[@to='#{key}']")&.text

    release == 'true'
  end

  def thumb
    document.root.at_xpath('thumb')&.text
  end

  def relations(predicate)
    document.root.xpath(
      "rdf:RDF/rdf:Description/fedora:#{predicate}",
      rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
      fedora: 'info:fedora/fedora-system:def/relations-external#'
    ).map do |node|
      node.attribute('resource').text.split('/', 2).last.split(':', 2).last
    end
  end

  def object_type
    document.root.at_xpath('identityMetadata/objectType')&.text
  end

  def source_id
    document.root.at_xpath('identityMetadata/sourceId')&.text
  end
end
