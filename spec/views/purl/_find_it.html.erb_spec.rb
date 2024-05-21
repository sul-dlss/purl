require 'rails_helper'

RSpec.describe 'purl/_find_it' do
  let(:purl) { instance_double(PurlResource, druid: 'cg357zz0321', catalog_key: nil) }

  context 'when not released' do
    before do
      allow(purl).to receive(:released_to?).with('Searchworks').and_return(false)
      allow(purl).to receive(:released_to?).with('Earthworks').and_return(false)
    end

    it 'does not display any links' do
      render 'purl/find_it', document: purl
      expect(rendered).to have_no_text 'Also listed in'
    end
  end

  context 'when released to SearchWorks' do
    before do
      allow(purl).to receive(:released_to?).with('Searchworks').and_return(true)
      allow(purl).to receive(:released_to?).with('Earthworks').and_return(false)
    end

    it 'displays a View in SearchWorks link using the druid' do
      render 'purl/find_it', document: purl
      expect(rendered).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/cg357zz0321'
    end

    context 'with a catkey' do
      before do
        allow(purl).to receive(:catalog_key).and_return('123456')
      end

      it 'displays a View in SearchWorks link using the catkey' do
        render 'purl/find_it', document: purl
        expect(rendered).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/123456'
      end
    end
  end

  context 'when released to EarthWorks' do
    before do
      allow(purl).to receive(:released_to?).with('Searchworks').and_return(false)
      allow(purl).to receive(:released_to?).with('Earthworks').and_return(true)
    end

    it 'displays a View in EarthWorks link using the druid' do
      render 'purl/find_it', document: purl
      expect(rendered).to have_link 'View in EarthWorks', href: 'https://earthworks.stanford.edu/catalog/stanford-cg357zz0321'
    end
  end

  context 'when released to both SearchWorks and EarthWorks' do
    before do
      allow(purl).to receive(:released_to?).with('Searchworks').and_return(true)
      allow(purl).to receive(:released_to?).with('Earthworks').and_return(true)
    end

    it 'displays both links' do
      render 'purl/find_it', document: purl
      expect(rendered).to have_text 'View in SearchWorks and View in EarthWorks'
    end
  end
end
