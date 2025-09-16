# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BibliographicComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:purl) { PurlResource.new(id: druid) }
  let(:druid) { 'bb000qr5025' }
  let(:version) { purl.version(:head) }

  before do
    puts render_inline(component)
  end

  it 'draws the bibliographic information' do
    expect(page).to have_css 'h2', text: 'Bibliographic information'
    expect(page).to have_content 'Original filepath'
    expect(page).to have_content "M2856_2022-330_b2_f3_CM017/LS_JJ_88a/LS_JJ_88a/LS_JJ_88-5A-50_Hunter's Point SF/88-5A-50_LS026.tif"
    expect(page).to have_content 'Original filename'
    expect(page).to have_content 'Source ID'
    expect(page).to have_content 'sul:M2856_2022-330_b2_f3_CM017_7fd9e107faf381c0d9bd67846f54cdee'
    expect(page).to have_content 'Repository'
    expect(page).to have_content 'Stanford University. Libraries. Department of Special Collections and University Archives'

    expect(page).to have_link 'https://purl.stanford.edu/bb000qr5025', href: 'https://purl.stanford.edu/bb000qr5025'
  end

  context 'with related items' do
    let(:druid) { 'bb253gh8060' }

    it 'draws the bibliographic information' do
      expect(page).to have_content 'Finding Aid'
      expect(page).to have_link 'Stanford University, Academic Council, Records (SC0193)', href: 'http://www.oac.cdlib.org/findaid/ark:/13030/kt5b69s0t3'
    end
  end
end
