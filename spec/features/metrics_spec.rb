# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Metrics display', js: true do
  let(:status) { 200 }
  let(:body) { '{"unique_views": 1}' }
  let(:druid) { 'bb157hs6068' }

  before do
    stub_request(:get, "https://sdr-metrics-api-prod.stanford.edu/#{druid}/metrics")
      .to_return(status:, body:, headers: { 'Content-Type' => 'application/json' })
    visit "/#{druid}"
  end

  it 'shows the number of views for a given object' do
    expect(page).to have_selector '#view-count', text: '1'
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

  describe 'downloads' do
    let(:body) { '{"unique_downloads": 1}' }

    context 'when the object is a file' do
      let(:druid) { 'nd387jf5675' }

      it 'shows the number of downloads' do
        expect(page).to have_selector '#download-count', text: '1'
      end
    end

    context 'when the object is a pdf' do
      let(:druid) { 'bh502xm3351' }

      it 'shows the number of downloads' do
        expect(page).to have_selector '#download-count', text: '1'
      end
    end

    context 'when the object is media' do
      let(:druid) { 'bd786fy6312' }

      it 'shows the number of downloads' do
        expect(page).to have_selector '#download-count', text: '1'
      end
    end

    context 'when the object is geospatial data' do
      let(:druid) { 'cz128vq0535' }

      it 'shows the number of downloads' do
        expect(page).to have_selector '#download-count', text: '1'
      end
    end

    context 'when the object is a 3d model' do
      let(:druid) { 'qf794pv6287' }

      it 'shows the number of downloads' do
        expect(page).to have_selector '#download-count', text: '1'
      end
    end

    context 'when the object is an image' do
      let(:druid) { 'cp088pb1682' }

      it 'shows the number of downloads' do
        expect(page).to have_selector '#download-count', text: '1'
      end
    end

    # can't be downloaded
    context 'when the object is a web archive' do
      let(:druid) { 'bd802vw5233' }

      it 'does not show the number of downloads' do
        expect(page).not_to have_selector '#download-count'
      end
    end

    # a collection
    context 'when the object is a collection' do
      let(:druid) { 'bb631ry3167' }

      it 'does not show the number of downloads' do
        expect(page).not_to have_selector '#download-count'
      end
    end
  end
end
