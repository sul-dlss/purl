require 'rails_helper'

RSpec.describe 'purl/_collection_items' do
  context 'when collection has a folio HRID' do
    let(:purl) { PurlResource.new(id: 'bb631ry3167') }

    it 'displays a View items in this collection link using the HRID' do
      # render
      render 'purl/collection_items', document: purl
      expect(rendered).to have_link 'View items in this collection in SearchWorks',
                                    href: 'https://searchworks.stanford.edu/catalog?f[collection][]=a13965062'
    end
  end

  context 'when collection does not have a folio HRID' do
    let(:purl) { PurlResource.new(id: 'gk894yk3598') }

    it 'displays a View items in this collection link using the druid' do
      # render
      render 'purl/collection_items', document: purl
      expect(rendered).to have_link 'View items in this collection in SearchWorks',
                                    href: 'https://searchworks.stanford.edu/catalog?f[collection][]=gk894yk3598'
    end
  end

  context 'when not a collection' do
    let(:purl) { PurlResource.new(id: 'cg357zz0321') }

    it 'does not display View items in this collection link' do
      # render
      render 'purl/collection_items', document: purl
      expect(rendered).to have_no_css 'a'
    end
  end

  context 'when not released to SearchWorks' do
    let(:purl) { PurlResource.new(id: 'ss099gb5528') }

    it 'does not display View items in this collection link' do
      # render
      render 'purl/collection_items', document: purl
      expect(rendered).to have_no_css 'a'
    end
  end
end
