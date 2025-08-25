# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'purl/_embed' do
  before { assign(:purl, purl) }

  let(:purl) { PurlResource.new(id: 'bf973rp9392') }

  it 'displays a purl embed viewer' do
    render
    expect(rendered).to have_css '.purl-embed-viewer'
    embed = Nokogiri::HTML(rendered).css('.purl-embed-viewer')
    expect(embed.attr('data-oembed-provider').to_s).to eq 'https://embed.stanford.edu/embed.json?hide_title=true&new_viewer=false'
    expect(embed.attr('href').to_s).to eq('https://purl.stanford.edu/bf973rp9392')
  end

  it 'displays a non-javascript fallback' do
    render
    expect(rendered).to have_css 'noscript iframe'
    iframe = Nokogiri::HTML(rendered).xpath('//iframe')
    expect(iframe.attr('src').to_s).to eq 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Fbf973rp9392'
  end

  context 'when a version is specified' do
    let(:version) { PurlVersion.new(id: 'bf973rp9392', head: true, state: 'available', version_id: 2) }

    before do
      assign(:version, version)
      allow_any_instance_of(ActionDispatch::Request).to receive(:path).and_return('/bf973rp9392/version/2') # rubocop:disable RSpec/AnyInstance
      allow(purl).to receive(:version).with(2).and_return(version)
    end

    it 'displays a purl embed viewer with the version' do
      render
      expect(rendered).to have_css '.purl-embed-viewer'
      embed = Nokogiri::HTML(rendered).css('.purl-embed-viewer')
      expect(embed.attr('data-oembed-provider').to_s).to eq 'https://embed.stanford.edu/embed.json?hide_title=true&new_viewer=false'
      expect(embed.attr('href').to_s).to eq('https://purl.stanford.edu/bf973rp9392/version/2')
    end

    it 'displays a non-javascript fallback' do
      render
      expect(rendered).to have_css 'noscript iframe'
      iframe = Nokogiri::HTML(rendered).xpath('//iframe')
      expect(iframe.attr('src').to_s).to eq 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Fbf973rp9392%2Fversion%2F2'
    end
  end

  context 'when a version is not specified' do
    let(:version) { PurlVersion.new(id: 'bf973rp9392', head: true, state: 'available', version_id: 1) }

    before do
      allow(purl).to receive(:version).and_return(version)
      allow_any_instance_of(ActionDispatch::Request).to receive(:path).and_return('/bf973rp9392') # rubocop:disable RSpec/AnyInstance
    end

    it 'does not display a purl embed viewer with a version' do
      render
      expect(rendered).to have_css '.purl-embed-viewer'
      embed = Nokogiri::HTML(rendered).css('.purl-embed-viewer')
      expect(embed.attr('data-oembed-provider').to_s).to eq 'https://embed.stanford.edu/embed.json?hide_title=true&new_viewer=false'
      expect(embed.attr('href').to_s).to eq('https://purl.stanford.edu/bf973rp9392')
    end

    it 'displays a non-javascript fallback' do
      render
      expect(rendered).to have_css 'noscript iframe'
      iframe = Nokogiri::HTML(rendered).xpath('//iframe')
      expect(iframe.attr('src').to_s).to eq 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Fbf973rp9392'
    end
  end
end
