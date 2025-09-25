# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContributorsComponent, type: :component do
  subject(:component) { described_class.new(version: version) }

  let(:purl) { Purl.new(id: druid) }
  let(:version) { purl.version(:head) }

  before do
    render_inline(component)
  end

  context 'with a book that has a contributor with no role and a publisher' do
    let(:druid) { 'bb737zp0787' }

    it 'shows the contributor name and excludes the publisher' do
      expect(page).to have_css 'section h2', text: 'Creators/Contributors'
      expect(page).to have_css 'th', text: 'Associated with'
      expect(page).to have_css 'td', text: 'Paget, Francis Edward, 1806-1882'
      expect(page).to have_no_content 'Publisher'
    end
  end

  context 'with a file item that has an ORCID for some contributors' do
    let(:druid) { 'wm135gp2721' }

    it 'shows ORCID links' do
      expect(page).to have_text(%r{Schroeder, Dustin\s+https://orcid.org/0000-0003-1916-3929\s*})
      orcid_link = page.find_link('https://orcid.org/0000-0003-1916-3929') # text of link
      expect(orcid_link['href']).to eq 'https://orcid.org/0000-0003-1916-3929'
      expect(orcid_link['aria-label']).to eq('view ORCID page for Schroeder, Dustin')

      icons = page.all('img[alt="ORCiD icon"]')
      expect(icons.size).to eq 3
      icons.each { |icon| expect(icon['src']).to eq 'https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png' }
    end
  end
end
