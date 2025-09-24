# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::HeadMetadataComponent, type: :component do
  subject(:component) { described_class.new(purl:, version:) }

  let(:purl) { PurlResource.new(id: druid) }
  let(:version) { purl.version(:head) }

  context 'with a version that is not the head' do
    let(:version) { purl.version(3) }

    let(:druid) { 'zb733jx3137' }

    before do
      # Required for embeddable_url to work correctly:
      vc_test_controller.request.path = '/zb733jx3137/version/3'
      render_inline(component)
    end

    it 'draws the page' do
      link = page.find('link[rel="alternate"][title="oEmbed Profile"][type="application/json+oembed"]', visible: false)
      expect(link['href']).to eq 'https://embed.stanford.edu/embed.json?url=https%3A%2F%2Fpurl.stanford.edu%2Fzb733jx3137%2Fversion%2F3'
      link = page.find('link[rel="alternate"][title="IIIF Manifest"]', visible: false)
      expect(link['href']).to eq 'http://purl.stanford.edu/zb733jx3137/iiif/manifest'
    end
  end

  context 'with a crawlable object that has aDOI' do
    let(:druid) { 'wm135gp2721' }

    before do
      render_inline(component)
    end

    it 'includes altmetrics and does not include robots meta tag' do
      expect(page).to have_no_css 'meta[name="robots"][content="noindex"]', visible: :hidden

      expect(page).to have_css 'meta[name="citation_doi"][content="10.25740/wm135gp2721"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_title"][content^="A Newly Digitised Ice-penetrating Radar Dataset"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_publication_date"][content="2023"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_author"][content="Karlsson, Nanna B."]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_author"][content="Schroeder, Dustin"]', visible: :hidden
    end
  end

  context 'with a book that is not crawlable' do
    let(:druid) { 'bb737zp0787' }

    before do
      render_inline(component)
    end

    it 'draws noindex meta tag' do
      expect(page).to have_css 'meta[name="robots"][content="noindex"]', visible: :hidden
      expect(page).to have_css 'link[rel=up][href="http://purl.stanford.edu/jt466yc7169"]', visible: :hidden
    end
  end

  describe 'schema_dot_org' do
    before do
      render_inline(component)
    end

    context 'with a dataset' do
      let(:druid) { 'wm135gp2721' }

      it 'draws schema.org markup' do
        expect(page).to have_css 'script[type="application/ld+json"]', visible: :hidden
      end
    end

    context 'with a video' do
      let(:druid) { 'bd699ky6829' }

      it 'draws schema.org markup' do
        expect(page).to have_css 'script[type="application/ld+json"]', visible: :hidden
      end
    end

    context 'with a format not relevant for schema.org' do
      let(:druid) { 'bb000qr5025' }

      it 'draws no markup' do
        expect(page).to have_no_css 'script[type="application/ld+json"]', visible: :hidden
      end
    end
  end
end
