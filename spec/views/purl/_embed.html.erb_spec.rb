require 'rails_helper'

RSpec.describe 'purl/_embed' do
  before do
    assign(:purl, purl)
  end

  let(:purl) { PurlResource.new(id: 'xyz') }

  it 'displays a purl embed viewer' do
    render
    expect(rendered).to have_selector '.purl-embed-viewer'
    embed = Nokogiri::HTML(rendered).css('.purl-embed-viewer')
    expect(embed.attr('data-oembed-provider').to_s).to eq 'https://embed.stanford.edu/embed.json?hide_title=true&hide_metadata=true'
  end

  it 'display a non-javascript fallback' do
    render
    expect(rendered).to have_selector 'noscript iframe'
    iframe = Nokogiri::HTML(rendered).xpath('//iframe')
    expect(iframe.attr('src').to_s).to eq 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Fxyz'
  end
end
