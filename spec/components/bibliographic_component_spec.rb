# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BibliographicComponent, type: :component do
  subject(:component) { described_class.new(mods: version.mods) }

  let(:purl) { PurlResource.new(id: druid) }
  let(:version) { purl.version(:head) }

  before do
    render_inline(component)
  end

  context 'with a location' do
    let(:druid) { 'bb000qr5025' }

    it 'has a link' do
      expect(page).to have_link 'https://purl.stanford.edu/bb000qr5025', href: 'https://purl.stanford.edu/bb000qr5025'
    end
  end
end
