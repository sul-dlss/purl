require 'rails_helper'

RSpec.describe 'purl', type: :feature do
  let(:unpublished_object) { 'fb123cd4567' }

  describe 'manifest' do
    context 'v2' do
      it 'renders the json for a book' do
        visit '/bc854fy5899/iiif/manifest'
        json_body = JSON.parse(page.body)
        expect(json_body['label']).to eq('John Wyclif and his followers, Tracts in Middle English')
        expect(json_body['metadata'].length).to eq 17
      end

      it 'renders the iiif v3 json for a file object' do
        visit '/wp335yr5649/iiif/manifest'
        json_body = JSON.parse(page.body)
        expect(json_body['@context']).to include('http://iiif.io/api/presentation/3/context.json')
        expect(json_body['id']).to eq 'http://www.example.com/wp335yr5649/iiif/manifest'
        expect(json_body['label']['en']).to include(start_with('Code and Data supplement to'))
      end
    end

    context 'v3' do
      context 'on a book' do
        it 'renders the json for manifest' do
          visit '/bc854fy5899/iiif3/manifest'
          json_body = JSON.parse(page.body)
          expect(json_body['label']['en'].first).to eq('John Wyclif and his followers, Tracts in Middle English')
          expect(json_body['metadata'].length).to eq 12
        end
      end

      context 'on a collection' do
        let(:purl_fetcher_response) do
          {
            'purls' => [
              {
                'druid' => 'cz120cp3134',
                'title' => 'Interview with Sheila McCabe',
                'object_type' => 'item',
                'content_type' => 'book',
                'true_targets' => ['Searchworks']
              }
            ],
            'pages' => { 'current' => 1, 'next' => nil }
          }
        end

        before do
          stub_request(:get, 'https://purl-fetcher-stage.stanford.edu/collections/druid:bb631ry3167/purls?page=1&per_page=1000')
            .to_return(status: 200, body: purl_fetcher_response.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'renders a iiif v3 collection manifest' do
          visit '/bb631ry3167/iiif/manifest'

          json_body = JSON.parse(page.body)
          expect(json_body['type']).to eq 'Collection'
        end

        it 'adds the member manifests as items' do
          visit '/bb631ry3167/iiif/manifest'

          json_body = JSON.parse(page.body)
          expect(json_body['items'].first).to eq(
            {
              'id' => 'http://www.example.com/cz120cp3134/iiif/manifest',
              'type' => 'Manifest',
              'label' => { 'en' => ['Interview with Sheila McCabe'] }
            }
          )
        end

        context 'when members have non-iiif content types' do
          let(:purl_fetcher_response) do
            {
              'purls' => [
                {
                  'druid' => 'cz120cp3134',
                  'title' => 'Interview with Sheila McCabe',
                  'object_type' => 'item',
                  'content_type' => 'audio',
                  'true_targets' => ['Searchworks']
                },
                {
                  'druid' => 'nx135fr3985',
                  'title' => 'Interview with Carson Smith',
                  'object_type' => 'item',
                  'content_type' => 'book',
                  'true_targets' => ['Searchworks']
                }
              ],
              'pages' => { 'current' => 1, 'next' => nil }
            }
          end

          it 'does not include them in the collection manifest' do
            visit '/bb631ry3167/iiif/manifest'
            json_body = JSON.parse(page.body)
            expect(json_body['items'].length).to eq 1 # only the book
          end
        end

        context 'when members are not released to public platforms' do
          let(:purl_fetcher_response) do
            {
              'purls' => [
                {
                  'druid' => 'cz120cp3134',
                  'title' => 'Interview with Sheila McCabe',
                  'object_type' => 'item',
                  'content_type' => 'audio',
                  'true_targets' => []
                }
              ],
              'pages' => { 'current' => 1, 'next' => nil }
            }
          end

          it 'does not include them in the collection manifest' do
            visit '/bb631ry3167/iiif/manifest'
            json_body = JSON.parse(page.body)
            expect(json_body['items']).to be_nil
          end
        end
      end
    end
  end

  describe 'annotation' do
    context 'v2' do
      it 'renders the json for a book' do
        visit '/bc854fy5899/iiif/annotation/bc854fy5899_1'
        json_body = JSON.parse(page.body)
        expect(json_body['motivation']).to eq('sc:painting')
      end

      it 'renders nil for a file object' do
        visit '/wp335yr5649/iiif/annotation/bc854fy5899_fdsa'
        expect(page.status_code).to eq(404)
      end
    end

    context 'v3' do
      it 'renders the json for a book' do
        visit '/bc854fy5899/iiif3/annotation/bc854fy5899_1'
        json_body = JSON.parse(page.body)
        expect(json_body['motivation']).to eq('painting')
      end

      it 'renders nil for a file object' do
        visit '/wp335yr5649/iiif3/annotation/bc854fy5899_fdsa'
        expect(page.status_code).to eq(404)
      end
    end
  end

  describe 'public xml' do
    it 'returns public xml' do
      visit '/xm166kd3734.xml'
      xml = Nokogiri::XML(page.body)
      expect(xml.search('//objectId').first.text).to eq('druid:xm166kd3734')
    end

    it '404 with unavailable message when no public_xml' do
      visit "/#{unpublished_object}.xml"
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested is not available.'
    end
  end

  describe 'mods' do
    it 'returns public mods' do
      visit '/xm166kd3734.mods'
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
