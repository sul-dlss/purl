require 'rails_helper'

#=begin

describe 'purl', type: :feature do
  before do
    @image_object = 'xm166kd3734'
    @file_object = 'wp335yr5649'
    @flipbook_object = 'bb737zp0787'
    @manifest_object = 'bc854fy5899'
    @embed_object = 'bf973rp9392'
    @incomplete_object = 'bb157hs6069'
    @unpublished_object = 'ab123cd4567'
    @legacy_object = 'ir:rs276tc2764'
    @nested_resources_object = 'dm907qj6498'
  end

  describe 'flipbook' do
    it 'should render the json for flipbook' do
      visit "/#{@flipbook_object}.flipbook"
      json_body = JSON.parse(page.body)
      expect(json_body['objectId']).to eq(@flipbook_object)
      expect(json_body['pages'].first).to include 'height' => 1901,
                                                  'width' => 1361,
                                                  'levels' => 6,
                                                  'resourceType' => 'page',
                                                  'stacksURL' => "#{Settings.stacks.url}/image/bb737zp0787/bb737zp0787_00_0002"
    end
    it 'offers an appropriate exception when the object is not a book' do
      visit "/#{@file_object}.flipbook"
      expect(page.status_code).to eq 404
    end
  end

  describe 'manifest' do
    it 'should render the json for manifest' do
      visit "/#{@manifest_object}/iiif/manifest.json"
      json_body = JSON.parse(page.body)
      expect(json_body['label']).to eq('John Wyclif and his followers, Tracts in Middle English')
    end
    it 'should render nil for a non-manifest' do
      visit "/#{@file_object}/iiif/manifest.json"
      expect(page.status_code).to eq(404)
    end
  end

  describe 'incomplete object' do
    it 'should render an error for an incompletely published item, but not 404' do
      visit "/#{@incomplete_object}"
      expect(page).to have_content 'The item you requested is not yet available. It will be available at this URL when Library processing is completed.'
    end
  end

  describe 'unpublished object' do
    it 'should 404 for an unpublished object' do
      visit "/#{@unpublished_object}"
      expect(page.status_code).to eq(404)
      expect(page.has_content?('The item you requested is not available.')).to eq(true)
    end
  end

  describe 'public xml' do
    it 'should fetch the public xml' do
      visit "/#{@image_object}.xml"
      xml = Nokogiri::XML(page.body)
      expect(xml.search('//objectId').first.text).to eq("druid:#{@image_object}")
    end
    it 'should fetch the public xml' do
      visit "/#{@unpublished_object}.xml"
      expect(page.status_code).to eq(404)
    end
  end

  describe 'mods' do
    it 'should get the public mods' do
      visit "/#{@image_object}.mods"
      xml = Nokogiri::XML(page.body)
      expect(xml.search('//mods:title', 'mods' => 'http://www.loc.gov/mods/v3').length).to be_present
    end
    it 'should fetch the public xml' do
      visit "/#{@unpublished_object}.mods"
      expect(page.status_code).to eq(404)
    end
  end

  describe 'invalid druid' do
    it 'should error on invalid druids' do
      visit '/abcdefg'
      expect(page).to have_content 'The item you requested does not exist'
      expect(page.status_code).to eq(404)
    end
  end

  describe 'legacy object' do
    it 'should handle a legacy object in a bizarre way' do
      new_path = '/' + @legacy_object.gsub(/^ir:/, '')
      visit "/#{@legacy_object}"
      # page.status_code.should == "302"
      expect(current_path).to eq(new_path)
    end
  end

  describe 'license' do
    it 'should have a license statement' do
      visit "/#{@file_object}"
      expect(page).to have_content 'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
    end
  end

  describe 'terms of use' do
    it 'should have terms of use' do
      visit "/#{@file_object}"
      expect(page).to have_content 'User agrees that, where applicable, content will not be used to identify or to otherwise infringe the privacy or'
    end
  end

  describe 'is_it_working' do
    it 'works' do
      visit '/is_it_working'
      expect(page.status_code).to eq 200
    end
  end
end

#=end
