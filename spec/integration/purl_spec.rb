require 'rails_helper'

RSpec.describe 'purl', type: :feature do
  before do
    @image_object = 'xm166kd3734'
    @file_object = 'wp335yr5649'
    @manifest_object = 'bc854fy5899'
    @embed_object = 'bf973rp9392'
    @annotation_list = 'hx163dc5225'
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
        expect(json_body['label']['en'].first).to eq('Page 1')
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

  describe 'annotationList' do
    let(:body) do
      <<~JSON
        {"@type":"oa:Annotation","motivation":"sc:painting","on":"https://purl.stanford.edu/hx163dc5225/iiif/canvas/hx163dc5225_9#xywh=0,0,2035,2531","resource":{"@id":"https://fromthepage.com/gkhalsa/19th-century-steinbeck-family-papers/a-sketch-of-the-life-of-john-a-steinbeck-the-dickson-family-and-the-jewish-mission-in-palestine-asia-approximately-30pp-233-c-1917/annotation/1264421/html/transcription","@type":"cnt:ContentAsText","format":"text/html","chars":"<p>before going out in the morning. But the <br/>\\nstepmother would not allow the children to <br/>\\nhave anything. However the affectionate <br/>\\n<a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51050&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51050' title='Peter GrossSteinbeck Sr.'>father</a> pitied poor little <a data-tooltip='https://fromthepage.com/article/tooltip?article_id=50914&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=50914' title='John Adolph Steinbeck'>John</a> out <br/>\\nin the early dawn cold tending the cows <br/>\\nand if the thrifty stepmother was not look-<br/>\\ning he would slip a slice of bread into <br/>\\nhis coat pocket for little <a data-tooltip='https://fromthepage.com/article/tooltip?article_id=50914&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=50914' title='John Adolph Steinbeck'>John</a>.(she only <br/>\\nlived a few years). After milking the cows <br/>\\n<a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51006&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51006' title='Katherine Steinbeck Theil'>Katherine</a> cut the clover, no matter how wet <br/>\\nand cold it was. And <a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51005&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51005' title='Peter GrossSteinbeck Jr.'>Peter</a> tied it in <br/>\\nbundles tied with strong bands. Put it in <br/>\\na cart and hauled it to the barn.</p>\\n\\n<p><a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51006&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51006' title='Katherine Steinbeck Theil'>Katherine</a> put straw in the cows stalls and <br/>\\nonce a week gave them a througher cleaning <br/>\\nout. At eight oclock the workers gathered <br/>\\nfor breakfast consisting of coffee potatoes <br/>\\nand bread and butter.</p>\\n\\n<p>Bread was baked once a month in a </p>","annotatedBy":[{"name":"Kireis"},{"name":"gkhalsa"}]}}\n
      JSON
    end
    let(:stacks_response) { instance_double(Faraday::Response, body: body.to_s) }

    context 'v2' do
      it 'renders the json for manifest' do
        allow(Faraday).to receive(:get).and_return(stacks_response)
        visit "/#{@annotation_list}/iiif/annotationList/hx163dc5225_9"
        json_body = JSON.parse(page.body)
        expect(json_body['@type']).to eq 'sc:AnnotationList'
        expect(json_body['@id']).to eq 'http://www.example.com/hx163dc5225/iiif/annotationList/hx163dc5225_9'
        expect(json_body.dig('resources', 0, '@type')).to eq 'oa:Annotation'
        expect(json_body.dig('resources', 0, 'resource', '@type')).to eq 'cnt:ContentAsText'
      end
    end
  end

  context 'incomplete/unpublished object (not in stacks)' do
    it 'gives 404 with unavailable message' do
      visit "/#{unpublished_object}"
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested is not available.'
      expect(page).to have_content 'This item is in processing or does not exist. If you believe you have reached this page in error, please send Feedback.'
    end

    it 'includes a feedback link that toggled the feedback form', :js do
      allow(Settings.feedback).to receive(:email_to).and_return('feedback@example.com')
      visit "/#{unpublished_object}"

      expect(page).to have_no_css('form.feedback-form', visible: :visible)

      within '#main-container' do
        click_on 'Feedback'
      end

      expect(page).to have_css('form.feedback-form', visible: :visible)
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

  describe 'invalid druid' do
    it '404 with invalid error message' do
      visit '/abcdefg'
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested does not exist.'
    end
  end

  describe 'legacy object id "ir:rs276tc2764"' do
    it 'routed to rs276tc2764' do
      new_path = '/' + @legacy_object.delete_prefix('ir:')
      visit "/#{@legacy_object}"
      expect(current_path).to eq(new_path)
    end
  end

  describe 'license' do
    it 'included in purl page' do
      visit "/#{@file_object}"
      expect(page).to have_content 'This work is licensed under an Open Data Commons Public Domain Dedication & License 1.0'
    end
  end

  describe 'terms of use' do
    it 'included in purl page' do
      visit "/#{@file_object}"
      expect(page).to have_content 'User agrees that, where applicable, content will not be used to identify or to otherwise infringe the privacy or'
    end
  end

  describe 'items in collection' do
    it 'included in purl page' do
      visit "/#{@collection}"
      expect(page).to have_content 'Items in collection'
      expect(page).to have_content 'View items in this collection in SearchWorks'
    end
  end
end
