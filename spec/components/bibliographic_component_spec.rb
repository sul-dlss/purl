# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BibliographicComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:purl) { Purl.new(id: druid) }
  let(:druid) { 'bb000qr5025' }
  let(:version) { purl.version(:head) }

  before do
    render_inline(component)
  end

  it 'draws the bibliographic information' do
    expect(page).to have_css 'h2', text: 'Bibliographic information'
    expect(page).to have_text 'Original filepath'
    expect(page).to have_text "M2856_2022-330_b2_f3_CM017/LS_JJ_88a/LS_JJ_88a/LS_JJ_88-5A-50_Hunter's Point SF/88-5A-50_LS026.tif"
    expect(page).to have_text 'Original filename'
    expect(page).to have_text 'Source ID'
    expect(page).to have_text 'sul:M2856_2022-330_b2_f3_CM017_7fd9e107faf381c0d9bd67846f54cdee'
    expect(page).to have_text 'Repository'
    expect(page).to have_text 'Stanford University. Libraries. Department of Special Collections and University Archives'

    expect(page).to have_link 'https://purl.stanford.edu/bb000qr5025', href: 'https://purl.stanford.edu/bb000qr5025'
  end

  context 'with a DOI' do
    let(:druid) { 'wm135gp2721' }

    it 'draws the DOI' do
      expect(page).to have_text 'DOI'
      expect(page).to have_link 'https://doi.org/10.25740/wm135gp2721', href: 'https://doi.org/10.25740/wm135gp2721'
    end
  end
end
