require 'rails_helper'

RSpec.describe 'purl/_collection_items' do
  context 'when collection has a folio HRID' do
    let(:document) { PurlVersion.new(id: 'bb631ry3167') }

    it 'displays a View items in this collection link using the HRID' do
      render('purl/collection_items', document:)
      expect(rendered).to have_link 'View items in this collection in SearchWorks',
                                    href: 'https://searchworks.stanford.edu/catalog?f[collection][]=a13965062'
    end
  end

  context 'when collection does not have a folio HRID' do
    let(:document) { PurlVersion.new(id: 'gk894yk3598') }

    it 'displays a View items in this collection link using the druid' do
      render('purl/collection_items', document:)
      expect(rendered).to have_link 'View items in this collection in SearchWorks',
                                    href: 'https://searchworks.stanford.edu/catalog?f[collection][]=gk894yk3598'
    end
  end

  context 'when not a collection' do
    let(:document) { PurlVersion.new(id: 'cg357zz0321') }

    it 'does not display View items in this collection link' do
      render('purl/collection_items', document:)
      expect(rendered).to have_no_css 'a'
    end
  end
end
