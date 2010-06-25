require 'nokogiri'

class Purl

  attr_accessor :dc, :properties, :identity, :content, :rights, :xml
  attr_accessor :titles, :authors, :degreeconfyr, :cclicense, :cclicensetype, :catalog_key, :read_group, :embargo_release_date
  attr_accessor :primary_files, :supplemental_files

  def retrieve_metadata(id) 
    @dc = retrieve_datastream_contents(id,'DC')
    @properties = retrieve_datastream_contents(id,'properties')
    @identity = retrieve_datastream_contents(id,'identityMetadata')
    @content = retrieve_datastream_contents(id,'contentMetadata')
    @rights = retrieve_datastream_contents(id,'rightsMetadata')
    @xml = "<objectType>#{@dc}#{@identity}#{@content}#{@rights}</objectType>"

    extract_dc_metadata(id,@dc)
    extract_properties_metadata(id,@properties)
    extract_identity_metadata(id,@identity)
    extract_content_metadata(id,@content)
    extract_rights_metadata(id,@rights)
  end
  
  private

  def extract_xpath_contents(doc,xpath)
    elements = doc.root.xpath(xpath).collect(&:text)
    elements.each do |elem|
      return elem.to_s
    end
    ''
  end

  # extract the relevant fields from the DC datastream
  def extract_dc_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      @titles = extract_xpath_contents(doc,"//dcterms:title")
      @authors = extract_xpath_contents(doc,"//dcterms:creator")
    end
  end
  
  # extract the relevant fields from the properties datastream
  def extract_properties_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      @degreeconfyr = extract_xpath_contents(doc,"//degreeconfyr")
      @cclicense = extract_xpath_contents(doc,"//cclicense")
      @cclicensetype = extract_xpath_contents(doc,"//cclicensetype")
    end
  end

  # extract the relevant fields from the identityMetadata datastream
  def extract_identity_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      @catalog_key = extract_xpath_contents(doc,"//otherId[@name='catkey']")
    end
  end

  # extract the relevant fields from the contentMetadata datastream
  def extract_content_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      # extract primary file metadata
      @primary_files = Array.new
      resource_xmls = doc.root.xpath("//resource[@type='main-augmented']")
      resource_xmls.each do |resource_xml|
        resource = Resource.new
        resource.objectId = resource_xml.xpath("@objectId").collect(&:text)
        resource.type = resource_xml.xpath("@type").collect(&:text)
        resource.mimetype = resource_xml.xpath("file/@mimetype").collect(&:text)
        resource.size = resource_xml.xpath("file/@size").collect(&:text)
        resource.shelve = resource_xml.xpath("file/@shelve").collect(&:text)
        resource.preserve = resource_xml.xpath("file/@preserve").collect(&:text)
        resource.deliver = resource_xml.xpath("file/@deliver").collect(&:text)
        resource.description_label = resource_xml.xpath("attr[@name='label']").collect(&:text)
        resource.filename = resource_xml.xpath("file/@id").collect(&:text)
        resource.url = resource_xml.xpath("file/location[@type='url']").collect(&:text)
        @primary_files.push(resource)
      end
      # extract supplemental file metadata
      @supplemental_files = Array.new
      resource_xmls = doc.root.xpath("//resource[@type='supplement']")
      resource_xmls.each do |resource_xml|
        resource = Resource.new
        resource.objectId = resource_xml.xpath("@objectId").collect(&:text)
        resource.type = resource_xml.xpath("@type").collect(&:text)
        resource.mimetype = resource_xml.xpath("file/@mimetype").collect(&:text)
        resource.size = resource_xml.xpath("file/@size").collect(&:text)
        resource.shelve = resource_xml.xpath("file/@shelve").collect(&:text)
        resource.preserve = resource_xml.xpath("file/@preserve").collect(&:text)
        resource.deliver = resource_xml.xpath("file/@deliver").collect(&:text)
        resource.sequence = resource_xml.xpath("@sequence").collect(&:text)
        resource.description_label = resource_xml.xpath("attr[@name='label']").collect(&:text)
        resource.filename = resource_xml.xpath("file/@id").collect(&:text)
        resource.url = resource_xml.xpath("file/location[@type='url']").collect(&:text)
        @supplemental_files.push(resource)
      end
    end
  end

  # extract the relevant fields from the rightsMetadata datastream
  def extract_rights_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      @read_group = extract_xpath_contents(doc,"//access[@type='read']/machine/group")
      @embargo_release_date = extract_xpath_contents(doc,"//embargoReleaseDate")
      if( !@embargo_release_date.nil? and @embargo_release_date != '' )
        embargo_date_time = Time.parse(@embargo_release_date)
        @embargo_release_date = '' unless embargo_date_time.future?
      end
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
