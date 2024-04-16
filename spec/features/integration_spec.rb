require 'rails_helper'

RSpec.describe 'Integration Scenarios' do
  context 'with an EEMs object' do
    it 'works' do
      visit '/mr497sx5638'
      expect(page).to have_content 'Statewide water action plan for California'
    end
  end

  context 'book' do
    it 'works' do
      visit '/bb737zp0787'
      expect(page).to have_content 'The curate of Cumberworth ; and The vicar of Roost : tales'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_content 'Associated with Paget, Francis Edward, 1806-1882'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Also listed in'
      expect(page).to have_content 'Vicar of Roost'
    end

    it 'has a link to the searchworks record' do
      visit '/bb737zp0787'
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/9616533'
    end

    it 'has a <link> to the collection' do
      visit '/bb737zp0787'
      expect(page).to have_css 'link[rel=up][href="http://www.example.com/jt466yc7169"]', visible: :hidden
    end
  end

  context 'map' do
    it 'works' do
      visit '/py305sy7961'
      expect(page).to have_content 'Torrance, Los Angeles Co., Cal., Dec. 1929'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Subjects'
    end

    it 'adds mailto links in the use and reproduction statement' do
      visit '/py305sy7961'
      expect(page).to have_link 'brannerlibrary@stanford.edu', href: 'mailto:brannerlibrary@stanford.edu'
    end
  end

  context 'etd' do
    it 'works' do
      visit '/nd387jf5675'
      expect(page).to have_content 'Invariance for perceptual recognition through deep learning'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Abstract/Contents'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Also listed in'
    end

    it 'has a link to the searchworks record' do
      visit '/nd387jf5675'
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/10734942'
    end
  end

  context 'item released to searchworks' do
    it 'works' do
      visit '/cp088pb1682'
      expect(page).to have_content 'Atari Competition'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Collection'
      expect(page).to have_metadata_section 'Also listed in'
    end

    it 'lists the collection name and links to items in collection' do
      visit '/cp088pb1682'
      expect(page).to have_content 'Bay Area video arcades : photographs by Ira Nowinski, 1981-1982'
      expect(page).to have_link 'View other items in this collection in SearchWorks', href: 'https://searchworks.stanford.edu/catalog?f[collection][]=a9685083'
    end

    it 'has a link to the searchworks record' do
      visit '/cp088pb1682'
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/cp088pb1682'
    end
  end

  context 'item that is part of collection not released to searchworks' do
    it 'lists the collection name and does not link to items in collection' do
      visit '/cd027gx5097'
      expect(page).to have_content 'Edward Flanders Ricketts papers, 1936-1979 (inclusive), 1936-1947 (bulk)'
      expect(page).to have_no_link 'View other items in this collection in SearchWorks'
    end
  end

  context 'cabinet minutes' do
    it 'works' do
      visit '/gx074xz5520'
      expect(page).to have_content 'Minutes, 2006 May 18'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Abstract/Contents'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Contact information'
    end

    it 'lists the collection name' do
      visit '/gx074xz5520'
      expect(page).to have_content 'Stanford University, Cabinet, Records'
    end

    it 'lists the preferred citation' do
      visit '/gx074xz5520'
      expect(page).to have_content 'Stanford University. Cabinet, Stanford University--Administration'
    end

    it 'shows related items' do
      visit '/gx074xz5520'
      expect(page).to have_link 'Finding aid', href: 'http://www.oac.cdlib.org/findaid/ark:/13030/kt1h4nf2fr/'
    end

    it 'provides the archivesref contact information' do
      visit '/gx074xz5520'
      expect(page).to have_link 'archivesref@stanford.edu', href: 'mailto:archivesref@stanford.edu'
    end
  end

  context 'revs object' do
    it 'works' do
      visit '/tx027jv4938'
      expect(page).to have_content 'IMSA 24 Hours of Daytona'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_content 'Revs ID 2012-015GHEW-BW-1984-b4_1.4_0003'
    end
  end

  context 'item with a DOI' do
    it 'includes altmetrics' do
      visit '/bb051dp0564'

      expect(page).to have_css 'meta[name="citation_doi"][content="10.25740/bb051dp0564"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_title"][content="The Distinct Impacts of Content Moderation"]', visible: :hidden
      # No publication date so falling back to deposit date
      expect(page).to have_css 'meta[name="citation_publication_date"][content="2022"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_author"][content="Khine, Sandi"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_author"][content="Navaroli, A. Collier"]', visible: :hidden
    end
  end

  context 'item with Stanford-only location in MODS' do
    it 'adds a Stanford-only indicator' do
      visit '/yk677wc8843'

      expect(page).to have_css '.stanford-only-text', text: 'Stanford only'
      expect(page.find('.stanford-only-text')).to have_sibling('a', text: 'Cambridge Core')
    end
  end

  context 'item with ORCID for some contributors' do
    it 'adds ORCID links' do
      visit '/wm135gp2721'

      expect(page).to have_text(%r{Schroeder, Dustin\s+https://orcid.org/0000-0003-1916-3929\s*\(unverified\)})
      orcid_link = page.find_link('https://orcid.org/0000-0003-1916-3929') # text of link
      expect(orcid_link['href']).to eq 'https://orcid.org/0000-0003-1916-3929'
      expect(orcid_link['aria-label']).to eq('view ORCID page for Schroeder, Dustin')

      icons = page.all('img[alt="ORCiD icon"]')
      expect(icons.size).to eq 3
      icons.each { |icon| expect(icon['src']).to eq 'https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png' }
    end
  end

  context 'an item that is not crawlable' do
    it 'includes noindex meta tag' do
      visit '/bb000br0025'
      expect(page).to have_css 'meta[name="robots"][content="noindex"]', visible: :hidden
    end
  end

  context 'an item that is crawlable' do
    it 'excludes noindex meta tag' do
      visit '/gb089bd2251'
      expect(page).to have_no_css 'meta[name="robots"][content="noindex"]', visible: :hidden
    end
  end

  def have_metadata_section(text)
    have_css 'section h2', text:
  end

  context 'dataset item' do
    it 'adds schema.org markup for Datasets' do
      visit '/wp335yr5649'
      expect(page).to have_css('script[type="application/ld+json"]', text: %r{http://schema.org}, visible: :hidden)
    end
  end
end
