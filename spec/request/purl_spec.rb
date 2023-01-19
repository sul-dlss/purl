require 'rails_helper'

RSpec.describe 'PURL API', type: :request do
  context 'PURL page' do
    it 'responds to OPTIONS requests' do
      options '/bb157hs6068'
      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Headers']).to include 'Accept'
    end

    context 'for an unknown format' do
      it 'returns 404 page' do
        get '/bb157hs6068.X55'
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include "The page you were looking for doesn't exist."
      end
    end
  end

  context 'IIIF v2 requests' do
    it 'redirects manifest.json requests' do
      get '/1/iiif/manifest.json'
      expect(response).to redirect_to('/1/iiif/manifest')
    end

    it 'redirects canvas json requests' do
      get '/1/iiif/canvas/whatever.json'
      expect(response).to redirect_to('/1/iiif/canvas/whatever')
    end

    it 'redirects annotation json requests' do
      get '/1/iiif/annotation/whatever.json'
      expect(response).to redirect_to('/1/iiif/annotation/whatever')
    end

    it 'responds to OPTIONS requests' do
      options '/bb157hs6068/iiif/manifest'
      expect(response).to be_successful
      expect(response.headers['Access-Control-Allow-Headers']).to include 'Accept'
    end
  end

  context 'IIIF v3 requests' do
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
      get '/1/iiif3/manifest.json'
      expect(response).to redirect_to('/1/iiif3/manifest')
    end

    it 'redirects canvas json requests' do
      get '/1/iiif3/canvas/whatever.json'
      expect(response).to redirect_to('/1/iiif3/canvas/whatever')
    end

    it 'redirects annotation json requests' do
      get '/1/iiif3/annotation/whatever.json'
      expect(response).to redirect_to('/1/iiif3/annotation/whatever')
    end
  end

  context 'Cocina page' do
    it 'returns the json' do
      get '/bb157hs6068.json'
      expect(response).to be_successful
      expect(response.body).to start_with('{"type":"http://cocina.sul.stanford.edu/models/collection.jsonld"')
    end
  end
end
