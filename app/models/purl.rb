require 'nokogiri'

class Purl

  attr_accessor :dc, :identity, :content, :rights, :xml
  attr_accessor :main_doc_title, :main_doc_url, :titles, :authors

  def retrieve_metadata(id) 
    @dc = retrieve_datastream_contents(id,'DC')
    @identity = retrieve_datastream_contents(id,'identityMetadata')
    @content = retrieve_datastream_contents(id,'contentMetadata')
    @rights = retrieve_datastream_contents(id,'rightsMetadata')
    @xml = "<objectType>#{@dc}#{@identity}#{@content}#{@rights}</objectType>"

    extract_dc_metadata(id,@dc)
    extract_identity_metadata(id,@identity)
    extract_content_metadata(id,content)
    extract_rights_metadata(id,@rights)
  end
  
  private

  # extract the relevant fields from the DC datastream
  def extract_dc_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      # titles
      elements = doc.root.xpath("//dcterms:title").collect(&:text)
      @titles = elements.map {|e| e.to_s}
      # authors
      elements = doc.root.xpath("//dcterms:creator").collect(&:text)
      @authors = elements.map {|e| e.to_s}
    end
  end

  # extract the relevant fields from the identityMetadata datastream
  def extract_identity_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
    end
  end

  # extract the relevant fields from the contentMetadata datastream
  def extract_content_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      @main_doc_title = doc.root.xpath("//resource[@type='main-augmented']/attr[@name='label']").collect(&:text)
      @main_doc_url = doc.root.xpath("//resource[@type='main-augmented']/file/location").collect(&:text)
    end
  end

  # extract the relevant fields from the rightsMetadata datastream
  def extract_rights_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
    end
  end

  def retrieve_datastream_contents(id,datastream)
    metadata = Dor::DorService.new.get_datastream_contents(id,datastream)
    if( metadata != nil )
      # remove the xml declaration if one exists
      metadata.gsub(/\<\?xml version=\"1\.0\"\?>/,'')
    else
      ''
    end
  end

end

