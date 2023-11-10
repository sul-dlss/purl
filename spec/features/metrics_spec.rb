# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Metrics display', js: true do
  let(:status) { 200 }
  let(:body) { '{"unique_views": 1}' }

  before do
    stub_request(:get, 'https://sdr-metrics-api-prod.stanford.edu/bb157hs6068/metrics')
      .to_return(status:, body:, headers: { 'Content-Type' => 'application/json' })
    visit '/bb157hs6068'
  end

  it 'shows the number of views for a given object' do
    expect(page).to have_selector 'th', text: /Views/i
    expect(page).to have_selector 'td', text: '1'
  end

  it 'includes a link to the metrics faq page' do
    expect(page).to have_link 'How are these metrics generated?'
  end

  context 'when the metrics API returns an error' do
    let(:status) { 500 }
    let(:body) { nil }

    it 'shows an error message' do
      expect(page).to have_text 'No usage metrics available.'
    end
  end
end
