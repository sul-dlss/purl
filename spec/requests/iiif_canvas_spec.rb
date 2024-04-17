require 'rails_helper'

RSpec.describe 'IIIF Canvas' do
  context 'when using v2' do
    it 'renders the json for manifest' do
      get '/bc854fy5899/iiif/canvas/bc854fy5899_1'
      expect(response.parsed_body['label']).to eq('Page 1')
    end

    it 'renders nil for a non-manifest' do
      get '/wp335yr5649/iiif/canvas/bc854fy5899_fdsa'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when using v3' do
    it 'renders the json for manifest' do
      get '/bc854fy5899/iiif3/canvas/bc854fy5899_1'
      expect(response.parsed_body['label']['en'].first).to eq('Page 1')
    end

    it 'renders nil for a non-manifest' do
      get '/wp335yr5649/iiif3/canvas/bc854fy5899_fdsa'
      expect(response).to have_http_status(:not_found)
    end
  end
end
