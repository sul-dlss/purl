require 'nokogiri'

require "dor/util"

class Purl

  include PurlHelper

  attr_accessor :pid
  attr_accessor :public_xml
  attr_accessor :titles, :authors                           # dc
  attr_accessor :degreeconfyr, :cclicense, :cclicensetype   # properites
  attr_accessor :catalog_key                                # identity
  attr_accessor :read_group, :embargo_release_date          # rights
  attr_accessor :primary_files, :supplemental_files         # content

  # constants
  # DOCUMENT_CACHE_ROOT = '/home/lyberadmin/document_cache'
  DOCUMENT_CACHE_ROOT = '/Users/dougkim/DLSS/projects/digital_stacks/development/document_cache'

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
    if( @public_xml == '' || @public_xml.nil? || !Dor::Util.is_shelved?(@pid) )
      return false
    end
    return true
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
      @titles = extract_xpath_contents(doc,"//dcterms:title")
      @authors = extract_xpath_contents(doc,"//dcterms:creator")
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
      # extract primary file metadata
      @primary_files = Array.new
      resource_xmls = doc.root.xpath("//resource[@type='main-augmented']")
      resource_xmls.each do |resource_xml|
        resource_doc = Nokogiri::XML(resource_xml.to_s)
        resource = Resource.new
        resource.objectId = extract_xpath_contents(resource_doc,"@objectId")
        resource.type = extract_xpath_contents(resource_doc,"@type")
        resource.mimetype = extract_xpath_contents(resource_doc,"file/@mimetype")
        size = extract_xpath_contents(resource_doc,"file/@size")
        resource.size = round_to(size.to_f/1000,2)
        resource.shelve = extract_xpath_contents(resource_doc,"file/@shelve")
        resource.preserve = extract_xpath_contents(resource_doc,"file/@preserve")
        resource.deliver = extract_xpath_contents(resource_doc,"file/@deliver")
        resource.description_label = extract_xpath_contents(resource_doc,"attr[@name='label']")
        resource.filename = extract_xpath_contents(resource_doc,"file/@id")
        resource.url = extract_xpath_contents(resource_doc,"file/location[@type='url']")
        @primary_files.push(resource)
      end
      # extract supplemental file metadata
      @supplemental_files = Array.new
      resource_xmls = doc.root.xpath("//resource[@type='supplement']")
      resource_xmls.each do |resource_xml|
        resource_doc = Nokogiri::XML(resource_xml.to_s)
        resource = Resource.new
        resource.objectId = extract_xpath_contents(resource_doc,"@objectId")
        resource.type = extract_xpath_contents(resource_doc,"@type")
        resource.mimetype = extract_xpath_contents(resource_doc,"file/@mimetype")
        size = extract_xpath_contents(resource_doc,"file/@size")
        resource.size = round_to(size.to_f/1000,2)
        resource.shelve = extract_xpath_contents(resource_doc,"file/@shelve")
        resource.preserve = extract_xpath_contents(resource_doc,"file/@preserve")
        resource.deliver = extract_xpath_contents(resource_doc,"file/@deliver")
        resource.sequence = extract_xpath_contents(resource_doc,"@sequence")
        resource.description_label = extract_xpath_contents(resource_doc,"attr[@name='label']")
        resource.filename = extract_xpath_contents(resource_doc,"file/@id")
        resource.url = extract_xpath_contents(resource_doc,"file/location[@type='url']")
        @supplemental_files.push(resource)
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
