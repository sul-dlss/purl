# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'purl/_collection_items' do
  context 'when collection has a folio HRID' do
    let(:resource_retriever) { VersionedResourceRetriever.new(druid: 'sk882gx0113', version_id: '1') }

    let(:version) { PurlVersion.new(id: 'sk882gx0113', resource_retriever:) }

    it 'displays a View items in this collection link using the HRID' do
      render('purl/collection_items', version:)
      expect(rendered).to have_link 'View items in this collection in SearchWorks',
                                    href: 'https://searchworks.stanford.edu/catalog?f[collection][]=a9685083'
    end
  end

  context 'when collection does not have a folio HRID' do
    let(:resource_retriever) { VersionedResourceRetriever.new(druid: 'gk894yk3598', version_id: '1') }

    let(:version) { PurlVersion.new(id: 'gk894yk3598', resource_retriever:) }

    it 'displays a View items in this collection link using the druid' do
      render('purl/collection_items', version:)
      expect(rendered).to have_link 'View items in this collection in SearchWorks',
                                    href: 'https://searchworks.stanford.edu/catalog?f[collection][]=gk894yk3598'
    end
  end

  context 'when not a collection' do
    let(:resource_retriever) { VersionedResourceRetriever.new(druid: 'cg357zz0321', version_id: '1') }

    let(:version) { PurlVersion.new(id: 'cg357zz0321', resource_retriever:) }

    it 'does not display View items in this collection link' do
      render('purl/collection_items', version:)
      expect(rendered).to have_no_css 'a'
    end
  end
end
