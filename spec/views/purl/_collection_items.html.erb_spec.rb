require 'rails_helper'

RSpec.describe 'purl/_collection_items' do
  before do
    assign(:purl, purl)
  end

  context 'when collection has a catalog record id' do
    let(:purl) { PurlResource.new(id: 'bb631ry3167') }

    it 'displays a View items in this collection link' do
      render
      expect(rendered).to have_css 'a[href="https://searchworks.stanford.edu/catalog?f[collection][]=13965062"]',
                                   text: 'View items in this collection in SearchWorks'
    end
  end

  context 'when collection does not have a catalog record id' do
    let(:purl) { PurlResource.new(id: 'gk894yk3598') }

    it 'does not display View items in this collection link' do
      render
      expect(rendered).not_to have_css 'a'
    end
  end

  context 'when not a collection' do
    let(:purl) { PurlResource.new(id: 'cg357zz0321') }

    it 'does not display View items in this collection link' do
      render
      expect(rendered).not_to have_css 'a'
    end
  end
end
