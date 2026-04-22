# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PURL preview' do
  describe 'POST /preview' do
    let(:cocina) do
      Rails.root.join('spec/fixtures/stacks/zb/733/jx/3137/zb733jx3137/versions/cocina.4.json').read
    end

    it 'renders preview sections from posted cocina json' do
      post '/preview', params: { cocina: }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Abstract/Contents')
      expect(response.body).to include('This is a test to see where the issue is with versioning with the review workflow on.')
      expect(response.body).to include('Description')
      expect(response.body).to include('Preferred citation')
      expect(response.body).to include('Testerton, C., NewAdvisor, C., Speaker, I., and Advisor, P. (2025).')
      expect(response.body).to include('Contact information')
      expect(response.body).to have_link('testing@me.com', href: 'mailto:testing@me.com')
    end
  end
end
