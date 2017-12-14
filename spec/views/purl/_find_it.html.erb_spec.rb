require 'rails_helper'

describe 'purl/_find_it.html.erb' do
  before do
    assign(:purl, purl)
  end

  context 'Content-type geo' do
    let(:purl) { PurlResource.new(id: 'cg357zz0321') }
    it 'displays a View in EarthWorks link' do
      render
      expect(rendered).to have_css 'a[href="https://earthworks.stanford.edu/catalog/stanford-cg357zz0321"]', text: 'View in EarthWorks'
    end
  end
  context 'Released to SearchWorks' do
    let(:purl) { PurlResource.new(id: 'bf973rp9392') }
    it 'displays a View in SearchWorks link' do
      render
      expect(rendered).to have_css 'a[href="https://searchworks.stanford.edu/view/bf973rp9392"]', text: 'View in SearchWorks'
    end
  end
end
