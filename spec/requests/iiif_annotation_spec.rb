# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IIIF Annotation' do
  context 'when using v2 path' do
    it 'redirects annotation json requests' do
      get '/bc000df0000/iiif/annotation/whatever.json'
      expect(response).to redirect_to('/bc000df0000/iiif/annotation/whatever')
    end

    it 'renders the json for a book' do
      get '/bc854fy5899/iiif/annotation/cocina-fileSet-bc854fy5899-bc854fy5899_1'
      json_body = response.parsed_body
      expect(json_body['motivation']).to eq('sc:painting')
    end

    it 'renders nil for a file object' do
      get '/wp335yr5649/iiif/annotation/bc854fy5899_fdsa'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when using v3 path' do
    it 'redirects annotation json requests' do
      get '/bc000df0000/iiif3/annotation/whatever.json'
      expect(response).to redirect_to('/bc000df0000/iiif3/annotation/whatever')
    end

    it 'renders the json for a book' do
      get '/bc854fy5899/iiif3/annotation/cocina-fileSet-bc854fy5899-bc854fy5899_1'
      expect(response.parsed_body['motivation']).to eq('painting')
    end

    it 'renders nil for a file object' do
      get '/wp335yr5649/iiif3/annotation/bc854fy5899_fdsa'
      expect(response).to have_http_status(:not_found)
    end
  end
end
