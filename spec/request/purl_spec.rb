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
