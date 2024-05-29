require 'rails_helper'

RSpec.describe 'purl/_find_it' do
  context 'Content-type geo' do
    let(:purl) { PurlResource.new(id: 'cg357zz0321') }

    it 'displays a View in EarthWorks link' do
      render 'purl/find_it', document: purl
      expect(rendered).to have_link 'View in EarthWorks', href: 'https://earthworks.stanford.edu/catalog/stanford-cg357zz0321'
    end
  end

  context 'Released to SearchWorks' do
    let(:purl) { PurlResource.new(id: 'bf973rp9392') }
    let(:release_metadata) { instance_double(ReleaseMetadata, released_to?: true) }

    before do
      allow(ReleaseMetadata).to receive(:new).and_return(release_metadata)
    end

    it 'displays a View in SearchWorks link' do
      render 'purl/find_it', document: purl
      expect(rendered).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/bf973rp9392'
    end
  end
end
