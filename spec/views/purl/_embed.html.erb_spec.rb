require 'rails_helper'

RSpec.describe 'purl/_embed' do
  before { assign(:purl, purl) }

  let(:purl) { PurlResource.new(id: 'xyz') }

  it 'displays a purl embed viewer' do
    render
    expect(rendered).to have_css '.purl-embed-viewer'
    embed = Nokogiri::HTML(rendered).css('.purl-embed-viewer')
    expect(embed.attr('data-oembed-provider').to_s).to eq 'https://embed.stanford.edu/embed.json?hide_title=true&hide_metadata=true'
    expect(embed.attr('href').to_s).to eq('https://purl.stanford.edu/xyz')
  end

  it 'displays a non-javascript fallback' do
    render
    expect(rendered).to have_css 'noscript iframe'
    iframe = Nokogiri::HTML(rendered).xpath('//iframe')
    expect(iframe.attr('src').to_s).to eq 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Fxyz'
  end

  context 'when a version is specified' do
    before { assign(:version, version) }

    let(:version) { PurlVersion.new(id: 'xyz', head: true, state: 'available', version_id: 2) }

    it 'displays a purl embed viewer' do
      render
      expect(rendered).to have_css '.purl-embed-viewer'
      embed = Nokogiri::HTML(rendered).css('.purl-embed-viewer')
      expect(embed.attr('data-oembed-provider').to_s).to eq 'https://embed.stanford.edu/embed.json?hide_title=true&hide_metadata=true'
      expect(embed.attr('href').to_s).to eq('https://purl.stanford.edu/xyz/version/2')
    end

    it 'displays a non-javascript fallback' do
      render
      expect(rendered).to have_css 'noscript iframe'
      iframe = Nokogiri::HTML(rendered).xpath('//iframe')
      expect(iframe.attr('src').to_s).to eq 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Fxyz%2Fversion%2F2'
    end
  end
end
