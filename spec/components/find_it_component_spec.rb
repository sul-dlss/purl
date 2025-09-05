# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindItComponent, type: :component do
  subject(:component) { described_class.new(releases:, version:) }

  let(:version) { instance_double(PurlVersion, catalog_key: '123', druid: 'cg357zz0321') }
  let(:releases) { instance_double(Releases, released_to_searchworks?: searchworks, released_to_earthworks?: earthworks) }

  before do
    render_inline(component)
  end

  context 'when released to EarthWorks and not SearchWorks' do
    let(:searchworks) { false }
    let(:earthworks) { true }

    it 'displays a View in EarthWorks link' do
      expect(page).to have_link 'View in EarthWorks', href: 'https://earthworks.stanford.edu/catalog/stanford-cg357zz0321'
    end
  end

  context 'when released to SearchWorks and EarthWorks' do
    let(:searchworks) { true }
    let(:earthworks) { true }

    it 'displays both links' do
      expect(page).to have_link 'View in EarthWorks', href: 'https://earthworks.stanford.edu/catalog/stanford-cg357zz0321'
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/123'
    end
  end

  context 'when released to SearchWorks and not EarthWorks' do
    let(:version) { instance_double(PurlVersion, catalog_key: nil, druid: 'bf973rp9392') }

    let(:searchworks) { true }
    let(:earthworks) { false }

    it 'displays a View in SearchWorks link' do
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/bf973rp9392'
    end
  end
end
