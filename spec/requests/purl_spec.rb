require 'rails_helper'

RSpec.describe 'PURL API' do
  describe 'root page' do
    context 'when html is requested' do
      it 'links to selected druids' do
        get '/'
        expect(response).to have_http_status(:ok)
        expect(response.body).to have_link 'John Wyclif and his followers, Tracts in Middle English'
      end
    end

    context 'when an unknown format is requested' do
      it 'returns 404 page' do
        get '/?format=xml'
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include "The page you were looking for doesn't exist."
      end
    end
  end

  describe 'PURL page' do
    it 'responds to OPTIONS requests' do
      options '/bb157hs6068'
      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Headers']).to include 'Accept'
    end

    context 'with an unknown format' do
      it 'returns 404 page' do
        get '/bb157hs6068.X55'
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include "The page you were looking for doesn't exist."
      end
    end

    context 'with json' do
      context 'when a version is not provided' do
        it 'returns the Cocina json' do
          get '/bb157hs6068.json'
          expect(response).to be_successful
          expect(response.parsed_body).to include('cocinaVersion', 'type', 'structural')
          expect(response.parsed_body['version']).to eq(9)
        end
      end

      context 'when a valid version is provided' do
        it 'returns the Cocina json for the requested version' do
          get '/wp335yr5649/version/4.json'
          expect(response).to be_successful
          expect(response.parsed_body).to include('cocinaVersion', 'type', 'structural')
          expect(response.parsed_body['version']).to eq(5)
        end
      end

      context 'when a missing version is provided' do
        it 'returns an HTTP 404 response' do
          get '/wp335yr5649/version/45.json'
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when a withdrawn version is provided' do
        let(:version) do
          PurlVersion.new(id: 'bw368gx2874',
                          version_id: 3,
                          head: false,
                          updated_at: 1.day.ago,
                          state: 'withdrawn',
                          resource_retriever:)
        end
        let(:resource_retriever) do
          instance_double(ResourceRetriever, public_xml_body: '<xml></xml>', cocina_body:)
        end
        let(:cocina_body) do
          '{"cocinaVersion": "0.100.text", "version": 5,"type": "https://cocina.sul.stanford.edu/models/image", "structural": {}}'
        end

        before do
          allow(PurlResource).to receive(:find).and_return(instance_double(PurlResource, version:))
        end

        it 'returns the Cocina json for the requested version' do
          get '/bw368gx2874/version/3.json'
          expect(response).to be_successful
          expect(response.parsed_body).to include('type', 'structural', 'status')
          expect(response.parsed_body['status']).to eq('withdrawn')
          expect(response.parsed_body['structural']['contains']).to eq([])
        end
      end
    end

    context 'with XML' do
      context 'when a version is not provided' do
        it 'returns the public XML' do
          get '/bb157hs6068.xml'
          expect(response).to be_successful
        end
      end

      context 'when a valid version is provided' do
        it 'returns the public XML for the requested version' do
          get '/wp335yr5649/version/4.xml'
          expect(response).to be_successful
        end
      end

      context 'when a missing version is provided' do
        it 'returns an HTTP 404 response' do
          get '/wp335yr5649/version/45.xml'
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when a withdrawn version is provided' do
        let(:version) do
          PurlVersion.new(id: 'bw368gx2874',
                          version_id: 3,
                          head: false,
                          updated_at: 1.day.ago,
                          state: 'withdrawn',
                          resource_retriever:)
        end
        let(:resource_retriever) do
          instance_double(ResourceRetriever, public_xml_body: '<xml></xml>', cocina_body:)
        end
        let(:cocina_body) do
          '{"cocinaVersion": "0.100.text", "version": 5,"type": "https://cocina.sul.stanford.edu/models/image", "structural": {}}'
        end

        before do
          allow(PurlResource).to receive(:find).and_return(instance_double(PurlResource, version:))
        end

        it 'returns the public XML for the requested version' do
          get '/bw368gx2874/version/3.xml'
          expect(response).to be_successful
        end
      end
    end

    context 'when meta_json is requested' do
      it 'returns the meta.json' do
        get '/bb157hs6068.meta_json'
        expect(response).to be_successful
        expect(response.parsed_body).to eq({ '$schemaVersion' => 1, 'searchworks' => true, 'earthworks' => true, 'sitemap' => false })
      end
    end

    context 'when html is requested' do
      it 'returns the PURL page of the head version' do
        get '/wp335yr5649'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(
          'Code and Data supplement to &quot;Deterministic Matrices Matching the ' \
          'Compressed Sensing Phase Transitions of Gaussian Random Matrices.&quot; -- VERSION 3'
        )
        expect(response.body).not_to include('A newer version of this item is available')
        expect(response.body).to have_css('div.upper-record-metadata')
        expect(response.body).to have_css('div.record-metadata')
      end

      context 'with legit version specified' do
        it 'returns the PURL page of the requested version' do
          get '/wp335yr5649/version/2'
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(
            'Code and Data supplement to &quot;Deterministic Matrices Matching the ' \
            'Compressed Sensing Phase Transitions of Gaussian Random Matrices.&quot; -- VERSION 1'
          )
          expect(response.body).to include('A newer version of this item is available')
          expect(response.body).to have_link('View latest version', href: 'http://www.example.com/wp335yr5649')
          expect(response.body).to have_css('div.upper-record-metadata')
          expect(response.body).to have_css('div.record-metadata')
        end
      end

      context 'with withdrawn version specified' do
        let(:version) do
          PurlVersion.new(id: 'bw368gx2874',
                          version_id: 3,
                          head: false,
                          updated_at: 1.day.ago,
                          state: 'withdrawn',
                          resource_retriever:)
        end
        let(:resource_retriever) do
          instance_double(ResourceRetriever, public_xml_body:, cocina_body:)
        end

        let(:public_xml_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <publicObject id="druid:bw368gx2874" published="2023-10-26T11:21:31Z" publishVersion="cocina-models/0.91.4">
              <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" version="3.7" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
                <titleInfo>
                  <title>Code and Data supplement to "Deterministic Matrices Matching the Compressed Sensing Phase Transitions of Gaussian Random Matrices." -- VERSION 3</title>
                </titleInfo>
              </mods>
            </publicObject>
          XML
        end
        let(:cocina_body) do
          '{"cocinaVersion": "0.100.text", "version": 5,"type": "https://cocina.sul.stanford.edu/models/image", "structural": {}}'
        end
        let(:purl_resource) { PurlResource.new(id: 'bw368gx2874') }

        before do
          allow(PurlResource).to receive(:find).and_return(purl_resource)
          allow(purl_resource).to receive_messages(version:, crawlable?: false)
        end

        it 'returns the PURL page of the requested version with only tombstone information' do
          get '/bw368gx2874/version/3'
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(
            'Code and Data supplement to &quot;Deterministic Matrices Matching the ' \
            'Compressed Sensing Phase Transitions of Gaussian Random Matrices.&quot; -- VERSION 3'
          )
          expect(response.body).not_to include('A newer version of this item is available')
          expect(response.body).to include('This version has been withdrawn')
          expect(response.body).to include('Please visit <a href="http://www.example.com/bw368gx2874">http://www.example.com/bw368gx2874</a> ' \
                                           'to view the other versions of this item.')
          expect(response.body).not_to include('Description')
          expect(response.body).not_to include('Preferred citation')
          expect(response.body).to have_no_css('div.upper-record-metadata')
          expect(response.body).to have_no_css('div.record-metadata')
        end
      end

      context 'with missing version specified' do
        it 'renders the head version page including a warning to the user' do
          get '/wp335yr5649/version/45'
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to('/wp335yr5649')
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Requested version \'45\' not found. Showing latest version instead.')
        end
      end
    end
  end

  context 'when requesting a IIIF v2 manifest' do
    it 'redirects manifest.json requests' do
      get '/bc000df0000/iiif/manifest.json'
      expect(response).to redirect_to('/bc000df0000/iiif/manifest')
    end

    it 'redirects canvas json requests' do
      get '/bc000df0000/iiif/canvas/whatever.json'
      expect(response).to redirect_to('/bc000df0000/iiif/canvas/whatever')
    end

    it 'redirects annotation json requests' do
      get '/bc000df0000/iiif/annotation/whatever.json'
      expect(response).to redirect_to('/bc000df0000/iiif/annotation/whatever')
    end

    it 'responds to OPTIONS requests' do
      options '/bb157hs6068/iiif/manifest'
      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Headers']).to include 'Accept'
    end
  end

  context 'when requesting a IIIF v3 manifest' do
    it 'using accept header provides v3 manifest' do
      get(
        '/bb157hs6068/iiif/manifest',
        params: {},
        headers: { 'Accept' => 'application/ld+json;profile="http://iiif.io/api/presentation/3/context.json"' }
      )
      expect(response.body).to include 'http://iiif.io/api/presentation/3/context.json'
    end

    it 'responds to OPTIONS requests' do
      options(
        '/bb157hs6068/iiif/manifest',
        params: {},
        headers: { 'Accept' => 'application/ld+json;profile="http://iiif.io/api/presentation/3/context.json"' }
      )

      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Headers']).to include 'Accept'
    end

    it 'redirects manifest.json requests' do
      get '/bc000df0000/iiif3/manifest.json'
      expect(response).to redirect_to('/bc000df0000/iiif3/manifest')
    end

    it 'redirects canvas json requests' do
      get '/bc000df0000/iiif3/canvas/whatever.json'
      expect(response).to redirect_to('/bc000df0000/iiif3/canvas/whatever')
    end

    it 'redirects annotation json requests' do
      get '/bc000df0000/iiif3/annotation/whatever.json'
      expect(response).to redirect_to('/bc000df0000/iiif3/annotation/whatever')
    end
  end
end
