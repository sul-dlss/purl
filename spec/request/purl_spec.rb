require 'rails_helper'

RSpec.describe 'PURL API', type: :request do
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
end
