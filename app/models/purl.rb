require 'nokogiri'

require "dor/util"

class Purl

  include PurlHelper

  attr_accessor :pid
  attr_accessor :public_xml
  attr_accessor :titles, :authors, :type, :source, :date, :relation, :description # dc
  attr_accessor :degreeconfyr, :cclicense, :cclicensetype  # properites
  attr_accessor :catalog_key                               # identity
  attr_accessor :read_group, :embargo_release_date         # rights
  attr_accessor :deliverable_files                         # content

  def initialize(id)
    @pid = id
    extract_metadata(@pid)
  end

  def extract_metadata(id)
    dc = get_metadata(id,'dc')
    properties = get_metadata(id,'properties')
    identityMetadata = get_metadata(id,'identityMetadata')
    contentMetadata = get_metadata(id,'contentMetadata')
    rightsMetadata = get_metadata(id,'rightsMetadata')
    @public_xml = get_metadata(id,'public')
    
    extract_dc_metadata(id,dc)
    extract_properties_metadata(id,properties)
    extract_identity_metadata(id,identityMetadata)
    extract_content_metadata(id,contentMetadata)
    extract_rights_metadata(id,rightsMetadata)
  end
  
  def is_ready?
    if @public_xml == '' or @public_xml.nil?
      return false
    end
    return true
  end
  
  # check if this object is of type image
  def is_image?
    if !@type.nil? && @type =~ /Image|Map/i
      return true
    end  
    return false
  end
  
  private

  def extract_xpath_contents(doc,xpath)
    elements = doc.root.xpath(xpath).collect(&:text)
    elements.each do |elem|
      return elem.to_s
    end
    ''
  end

  # extract the relevant fields from the dc metadata
  def extract_dc_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      doc.remove_namespaces!
      
      @titles      = extract_xpath_contents(doc,"title")
      @authors     = extract_xpath_contents(doc,"creator")
      @type        = extract_xpath_contents(doc,"type")
      @source      = extract_xpath_contents(doc,"source")
      @date        = extract_xpath_contents(doc,"date")
      @description = extract_xpath_contents(doc,"description")
      @relation    = extract_xpath_contents(doc,"relation").gsub /^Collection\s*:\s*/, ''
    end
  end
  
  # extract the relevant fields from the properties metadata
  def extract_properties_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      @degreeconfyr = extract_xpath_contents(doc,"//degreeconfyr")
      @cclicense = extract_xpath_contents(doc,"//cclicense")
      @cclicensetype = extract_xpath_contents(doc,"//cclicensetype")
    end
  end

  # extract the relevant fields from the identityMetadata metadata
  def extract_identity_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      @catalog_key = extract_xpath_contents(doc,"//otherId[@name='catkey']")
    end
  end

  # extract the relevant fields from the content metadata
  def extract_content_metadata(id,metadata)
    if( metadata != '' )
      doc = Nokogiri::XML(metadata)
      
      # extract deliverable files
      @deliverable_files = Array.new
      resource_xmls = doc.root.xpath("//resource")
      
      resource_xmls.each do |resource_xml|
        resource_doc = Nokogiri::XML(resource_xml.to_s)
        files_xmls = resource_doc.xpath("//file[@deliver='yes']")
        
        files_xmls.each do |file_xml|
          file_doc = Nokogiri::XML(file_xml.to_s)
          resource = Resource.new
          
          resource.objectId = extract_xpath_contents(resource_doc,"@objectId")
          resource.type     = extract_xpath_contents(resource_doc,"@type")
          resource.description_label = extract_xpath_contents(resource_doc,"attr[@name='label']")
          resource.mimetype = extract_xpath_contents(file_doc,"@mimetype")
          resource.size     = extract_xpath_contents(file_doc,"@size")
          resource.shelve   = extract_xpath_contents(file_doc,"@shelve")
          resource.preserve = extract_xpath_contents(file_doc,"@preserve")
          resource.deliver  = extract_xpath_contents(file_doc,"@deliver")
          resource.filename = extract_xpath_contents(file_doc,"@id")
          resource.url      = extract_xpath_contents(file_doc,"location[@type='url']")
          
          resource.imagesvc = extract_xpath_contents(file_doc,"location[@type='imagesvc']")
          resource.width    = extract_xpath_contents(file_doc,"imageData/@width")
          resource.height   = extract_xpath_contents(file_doc,"imageData/@height")

          @deliverable_files.push(resource)
        end
        
      end
    end
  end

  # extract the relevant fields from the rights metadata
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

  # retrieve the given document from the document cache for the given object identifier
  def get_metadata(id,doc_name)
    pair_tree = create_pair_tree(id)
    unless( pair_tree.nil? )
      file_path = File.join(DOCUMENT_CACHE_ROOT,pair_tree,doc_name)
      if( File::exists? file_path )
        file = File.new(file_path,'r')
        contents = file.read
        # replace stacks urls with stacks-test urls in the contentMetadata depending on the environment
        if( !RAILS_ENV.eql? 'production' )
          contents.gsub!('stacks.stanford.edu','stacks-test.stanford.edu')
        end
        return contents
      end
    end
    ''
  end

end
