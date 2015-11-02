require 'rails_helper'

describe 'purl', type: :feature do
  before do
    @image_object = 'xm166kd3734'
    @file_object = 'wp335yr5649'
    @manifest_object = 'bc854fy5899'
    @embed_object = 'bf973rp9392'
    @unpublished_object = 'ab123cd4567'
    @legacy_object = 'ir:rs276tc2764'
    @nested_resources_object = 'dm907qj6498'
  end

  describe 'manifest' do
    context 'v2' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif/manifest"
        json_body = JSON.parse(page.body)
        expect(json_body['label']).to eq('John Wyclif and his followers, Tracts in Middle English')
        expect(json_body['metadata'].length).to eq 17
      end
      it 'renders nil for a non-manifest' do
        visit "/#{@file_object}/iiif/manifest"
        expect(page.status_code).to eq(404)
      end
    end
    context 'v3' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif3/manifest"
        json_body = JSON.parse(page.body)
        expect(json_body['label']).to eq('John Wyclif and his followers, Tracts in Middle English')
        expect(json_body['metadata'].length).to eq 17
      end
    end
  end

  describe 'canvas' do
    context 'v2' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif/canvas/bc854fy5899_1"
        json_body = JSON.parse(page.body)
        expect(json_body['label']).to eq('Page 1')
      end
      it 'renders nil for a non-manifest' do
        visit "/#{@file_object}/iiif/canvas/bc854fy5899_fdsa"
        expect(page.status_code).to eq(404)
      end
    end
    context 'v3' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif3/canvas/bc854fy5899_1"
        json_body = JSON.parse(page.body)
        expect(json_body['label']).to eq('Page 1')
      end
      it 'renders nil for a non-manifest' do
        visit "/#{@file_object}/iiif3/canvas/bc854fy5899_fdsa"
        expect(page.status_code).to eq(404)
      end
    end
  end

  describe 'annotation_page' do
    context 'v3' do
      it 'renders the json for manifest' do
        visit "/#{@manifest_object}/iiif3/annotation_page/bc854fy5899_1"
        json_body = JSON.parse(page.body)
        expect(json_body['items'].first['motivation']).to eq('painting')
      end
      it 'renders nil for a non-manifest' do
        visit "/#{@file_object}/iiif3/annotation_page/bc854fy5899_fdsa"
        expect(page.status_code).to eq(404)
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

  context 'incomplete/unpublished object (not in stacks)' do
    it 'gives 404 with unavailable message' do
      visit "/#{@unpublished_object}"
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested is not available.'
      expect(page).to have_content 'This item is in processing or does not exist. If you believe you have reached this page in error, please send Feedback.'
    end

    it 'includes a feedback link that toggled the feedback form', js: true do
      visit "/#{@unpublished_object}"

      expect(page).not_to have_css('form.feedback-form', visible: true)

      within '#main-container' do
        click_link 'Feedback'
      end

      expect(page).to have_css('form.feedback-form', visible: true)
    end
  end

  describe 'public xml' do
    it 'returns public xml' do
      visit "/#{@image_object}.xml"
      xml = Nokogiri::XML(page.body)
      expect(xml.search('//objectId').first.text).to eq("druid:#{@image_object}")
    end
    it '404 with unavailable message when no public_xml' do
      visit "/#{@unpublished_object}.xml"
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
      visit "/#{@unpublished_object}.mods"
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested is not available.'
    end
  end

  describe 'invalid druid' do
    it '404 with invalid error message' do
      visit '/abcdefg'
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested does not exist.'
    end
  end

  describe 'legacy object id "ir:rs276tc2764"' do
    it 'routed to rs276tc2764' do
      new_path = '/' + @legacy_object.gsub(/^ir:/, '')
      visit "/#{@legacy_object}"
      expect(current_path).to eq(new_path)
    end
  end

  describe 'license' do
    it 'included in purl page' do
      visit "/#{@file_object}"
      expect(page).to have_content 'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
    end
  end

  describe 'terms of use' do
    it 'included in purl page' do
      visit "/#{@file_object}"
      expect(page).to have_content 'User agrees that, where applicable, content will not be used to identify or to otherwise infringe the privacy or'
    end
  end

  describe '/status  (app monitoring)' do
    it 'has response code 200' do
      visit '/status'
      expect(page.status_code).to eq 200
      expect(page).to have_text('Application is running')
    end
  end
end
