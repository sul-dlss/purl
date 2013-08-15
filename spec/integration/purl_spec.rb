require 'spec_helper'

#=begin

describe 'purl' do
  before do
    @image_object='xm166kd3734'
    @file_object='wp335yr5649'
    @flipbook_object = 'yr183sf1341'
    @embed_object = 'bf973rp9392'
    @incomplete_object = 'bb157hs6069'
    @unpublished_object = 'ab123cd4567'
    @legacy_object='ir:rs276tc2764'
    @no_mods_object = 'dh395xy5058'
    @nested_resources_object = 'dm907qj6498'
  end

  describe 'gallery view' do
    it 'should render a gallery view' do
      visit "/#{@image_object}"
      #should have the title; the title is in an h4 so cant use a selector
      page.has_content?('Walters Ms. W.12, On Christian rulers').should == true
      #the date should be present
      page.has_content?("Mid 12th century CE").should == true
      #the first image in the image gallery view should be there and have the correct id
      img_tags = all(:css, 'li div.img-block a img')
      img_tag = img_tags.first
      img_tag[:id].should == "img-src-W12_000001_300"
    end
    it 'should render a gallery view for nested resources' do
      visit "/#{@nested_resources_object}"
      #should have the title; the title is in an h4 so cant use a selector
      page.has_content?('Stanford University student life').should == true
      #the date should be present
      page.has_content?("1896-1897").should == true
      #the first image in the image gallery view should be there and have the correct id
      img_tags = all(:css, 'li div.img-block a img')
      img_tag = img_tags.first
      img_tag[:id].should == "img-src-dm907qj6498_05_0001"
    end
  end

  describe 'flipbook' do
    it 'should render a flipbook view' do
      visit "/#{@flipbook_object}"
      #should have the title; the title is in an h4 so cant use a selector
      page.has_content?("Islamic prayer book, 1228 H").should == true
      #should have a thumbnail
      thumbnail = find("div.thumb-img-box img")
      thumbnail[:src].should == 'http://stacks-test.stanford.edu/image/yr183sf1341/yr183sf1341_05_0001_thumb'
      #should have a 'read online' link
      read_link = find("div.thumb-img-box div.view-in-bookreader a")
      read_link[:href].should == "javascript:showFullScreen();"
    end
    it 'should render the json for flipbook' do
      visit "/#{@flipbook_object}.flipbook"
      json_body=JSON.parse(page.text)
      json_body['objectId'].should == @flipbook_object
      json_body['pages'].first.should == JSON.parse('{"height":2332,"width":2865,"levels":6,"resourceType":"page","label":null,"stacksURL":"http://stacks-test.stanford.edu/image/yr183sf1341/yr183sf1341_05_0001"}')
    end
    it 'should render nil for a non-flipbook' do
      visit "/#{@file_object}.flipbook"
      page.text.should == 'null'
    end
  end

  describe 'file view' do
    it 'should render a regular file list' do
      visit "/#{@file_object}"
      #should have the title; the title is in an h4 so cant use a selector
      page.has_content?('Code and Data supplement to "Deterministic Matrices Matching the Compressed Sensing Phase Transitions of Gaussian Random Matrices."').should == true
      #should have 4 file links, and the first should be the readme
      file_links = all 'td.file div.file_link a'
      file_links.length.should == 4
      file_links.first[:href].should == "http://stacks-test.stanford.edu/file/druid:wp335yr5649/README.txt"
    end
  end

  describe 'embeded viewer' do
    it 'should have the needed json embedded in a javascript variable' do
      #capybara wants a real html document, not a weird fragment. picky picky. use rspec.
      get "/bf973rp9392/embed-js"
      #this is a crummy way to test for the presence of the data, but it is embedded as a javascript variable. Once it is a separate json path, this can be done in a better way
      response.body.include?('var peImgInfo = [ { "id": "bf973rp9392_00_0001","label": "Item 1","width": 1740,"height": 1675,"sequence": 1,"rightsWorld": "true","rightsWorldRule": "","rightsStanford": "false","rightsStanfordRule": "",}').should == true
      response.body.include?('var peStacksURL = "http://stacks-test.stanford.edu";').should == true
    end
    it 'should 404 if the item isnt an image object for /druid/embed-js' do
      visit "/#{@file_object}/embed-js"
      page.status_code.should == 404
    end
    it 'should 404 if the item isnt an image object for /druid/embed-html-json' do
      visit "/#{@file_object}/embed-html-json"
      page.status_code.should == 404
    end
    it 'should 404 if the item isnt an image object for /druid/embed' do
      visit "/#{@file_object}/embed"
      page.status_code.should == 404
    end
    it 'should get the html-json data' do
      get "/#{@embed_object}/embed-html-json"
      response.body.include?('{ "id": "bf973rp9392_00_0002","label": "Item 2","width": 1752,"height": 1687,"sequence": 2,"rightsWorld": "true","rightsWorldRule": "","rightsStanford": "false","rightsStanfordRule": "",}').should == true
    end
    it 'should 404 for an unpublished object' do
      visit "/#{@unpublished_object}/embed-html-json"
      page.status_code.should == 404
      #this is from 404.html....not sure why but thats how the app works
      page.has_content?('The page you were looking for doesn\'t exist.').should == true
    end
    it 'should render the embed view' do
      get "/#{@embed_object}/embed"
      response.body.include?('var peImgInfo = [ { "id": "bf973rp9392_00_0001","label": "Item 1","width": 1740,"height": 1675,"sequence": 1,"rightsWorld": "true","rightsWorldRule": "","rightsStanford": "false","rightsStanfordRule": "",}').should == true
      response.body.include?('var peStacksURL = "http://stacks-test.stanford.edu";').should == true
    end
    it 'should 404 for an unpublished object' do
      visit "/#{@unpublished_object}/embed"
      page.status_code.should == 404
      #this is from 404.html....not sure why but thats how the app works
      page.has_content?('The page you were looking for doesn\'t exist.').should == true
    end
    it 'should error on invalid druids' do
      visit '/abcdefg/embed'
      page.status_code.should == 404
    end

  end

  describe 'incomplete object' do
    it 'should render an error for an incompletely published item, but not 404' do
      visit "/#{@incomplete_object}"
      page.has_content?('The item you requested is not yet available. It will be available at this URL when Library processing is completed.').should == true
    end
  end

  describe 'unpublished object' do
    it 'should 404 for an unpublished object' do
      visit "/#{@unpublished_object}"
      page.status_code.should == 404
      page.has_content?('The item you requested is not available.').should == true
    end
  end

  describe 'public xml' do
    it 'should fetch the public xml' do
      get "/#{@image_object}.xml"
      xml=Nokogiri::XML(response.body)
      xml.search('//objectId').first.text.should == "druid:#{@image_object}"
    end
    it 'should fetch the public xml' do
      visit "/#{@unpublished_object}.xml"
      page.status_code.should == 404
    end
  end

  describe 'mods' do
    it 'should get the public mods' do
      get "/#{@image_object}.mods"
      xml=Nokogiri::XML(response.body)
      xml.search('//mods:title', 'mods' => 'http://www.loc.gov/mods/v3').length.should == 1
    end
    it 'should fetch the public xml' do
      visit "/#{@unpublished_object}.mods"
      page.status_code.should == 404
    end
    it 'should 404 if there is no mods file' do
      visit "/#{@no_mods_object}.mods"
      page.status_code.should == 404
    end
  end

  describe 'invalid druid' do
    it 'should error on invalid druids' do
      visit '/abcdefg'
      page.has_content?('The item you requested does not exist').should == true
      page.status_code.should == 404
    end
  end

  describe 'legacy object' do
    it 'should handle a legacy object in a bizarre way' do
      visit "/#{@legacy_object}"
      page.has_content?('Reassessing authorship of the Book of Mormon using delta and nearest shrunken centroid classification').should == true
    end
  end

  describe 'license' do
    it 'should have a license statement' do
      visit "/#{@file_object}"
      page.has_content?('This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)').should == true
    end
  end

  describe 'terms of use' do
    it 'should have terms of use' do
      visit "/#{@file_object}"
      page.has_content?('User agrees that, where applicable, content will not be used to identify or to otherwise infringe the privacy or').should == true
    end
  end
end

#=end