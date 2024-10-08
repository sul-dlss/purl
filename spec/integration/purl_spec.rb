require 'rails_helper'

RSpec.describe 'purl', type: :feature do
  before do
    @image_object = 'xm166kd3734'
    @file_object = 'wp335yr5649'
    @manifest_object = 'bc854fy5899'
    @embed_object = 'bf973rp9392'
    @legacy_object = 'ir:rs276tc2764'
    @nested_resources_object = 'dm907qj6498'
    @collection = 'bb631ry3167'
  end

  let(:unpublished_object) { 'fb123cd4567' }

  describe 'manifest' do
    context 'v2' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif/manifest"
        json_body = JSON.parse(page.body)
        expect(json_body['label']).to eq('John Wyclif and his followers, Tracts in Middle English')
        expect(json_body['metadata'].length).to eq 17
      end

      it 'renders the iiif v3 json for a non-image object' do
        visit "/#{@file_object}/iiif/manifest"
        json_body = JSON.parse(page.body)
        expect(json_body['@context']).to include('http://iiif.io/api/presentation/3/context.json')
        expect(json_body['id']).to eq "http://www.example.com/#{@file_object}/iiif/manifest"
        expect(json_body['label']['en']).to include(start_with('Code and Data supplement to'))
      end
    end

    context 'v3' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif3/manifest"
        json_body = JSON.parse(page.body)
        expect(json_body['label']['en'].first).to eq('John Wyclif and his followers, Tracts in Middle English')
        expect(json_body['metadata'].length).to eq 11
      end

      it 'renders a iiif v3 collection manifest for a collection' do
        visit "/#{@collection}/iiif/manifest"

        json_body = JSON.parse(page.body)
        expect(json_body['type']).to eq 'Collection'
      end
    end
  end

  describe 'annotation' do
    context 'v2' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif/annotation/bc854fy5899_1"
        json_body = JSON.parse(page.body)
        expect(json_body['motivation']).to eq('sc:painting')
      end

      it 'renders nil for a non-manifest' do
        visit "/#{@file_object}/iiif/annotation/bc854fy5899_fdsa"
        expect(page.status_code).to eq(404)
      end
    end

    context 'v3' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif3/annotation/bc854fy5899_1"
        json_body = JSON.parse(page.body)
        expect(json_body['motivation']).to eq('painting')
      end

      it 'renders nil for a non-manifest' do
        visit "/#{@file_object}/iiif3/annotation/bc854fy5899_fdsa"
        expect(page.status_code).to eq(404)
      end
    end
  end

  describe 'public xml' do
    it 'returns public xml' do
      visit "/#{@image_object}.xml"
      xml = Nokogiri::XML(page.body)
      expect(xml.search('//objectId').first.text).to eq("druid:#{@image_object}")
    end

    it '404 with unavailable message when no public_xml' do
      visit "/#{unpublished_object}.xml"
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested is not available.'
    end
  end

  describe 'mods' do
    it 'returns public mods' do
      visit "/#{@image_object}.mods"
      xml = Nokogiri::XML(page.body)
      expect(xml.search('//mods:title', 'mods' => 'http://www.loc.gov/mods/v3').length).to be_present
    end

    it '404 with unavailable message when no mods' do
      visit "/#{unpublished_object}.mods"
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested is not available.'
    end
  end
end
