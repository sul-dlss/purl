require 'rails_helper'

describe 'purl/_embed.html.erb' do
  before do
    assign(:purl, purl)
  end

  let(:purl) { PurlResource.new(id: 'xyz') }

  context 'for a book item' do
    before do
      allow(purl).to receive(:flipbook?).and_return(true)
    end

    it 'display a flipbook viewer' do
      render
      expect(rendered).to have_selector 'iframe'
      iframe = Nokogiri::HTML(rendered).xpath('//iframe')
      expect(iframe.attr('src').to_s).to eq '//sul-reader.stanford.edu/flipbook2/embed.jsp?id=xyz'
    end
  end

  context 'for an image item' do
    before do
      allow(purl).to receive(:flipbook?).and_return(false)
    end

    it 'displays a purl embed viewer' do
      render
      expect(rendered).to have_selector '.purl-embed-viewer'
      embed = Nokogiri::HTML(rendered).css('.purl-embed-viewer')
      expect(embed.attr('data-oembed-provider').to_s).to eq 'https://purl.stanford.edu/embed.json?hide_title=true&hide_metadata=true'
    end

    it 'display a non-javascript fallback' do
      render
      expect(rendered).to have_selector 'noscript iframe'
      iframe = Nokogiri::HTML(rendered).xpath('//iframe')
      expect(iframe.attr('src').to_s).to eq 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Fxyz'
    end
  end
end
