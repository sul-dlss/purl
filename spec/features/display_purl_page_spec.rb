require 'rails_helper'

RSpec.describe 'Displaying the PURL page' do
  context 'book' do
    let(:druid) { 'bb737zp0787' }

    it 'displays the page' do
      visit "/#{druid}"
      expect(page).to have_content 'The curate of Cumberworth ; and The vicar of Roost : tales'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_content 'Associated with Paget, Francis Edward, 1806-1882'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Also listed in'
      expect(page).to have_content 'Vicar of Roost'
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/9616533'
      expect(page).to have_css 'link[rel=up][href="http://www.example.com/jt466yc7169"]', visible: :hidden
    end
  end

  context 'map' do
    let(:druid) { 'py305sy7961' }

    it 'displays the page' do
      visit "/#{druid}"
      expect(page).to have_content 'Torrance, Los Angeles Co., Cal., Dec. 1929'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_link 'brannerlibrary@stanford.edu', href: 'mailto:brannerlibrary@stanford.edu'
    end
  end

  context 'etd' do
    let(:druid) { 'nd387jf5675' }

    it 'displays the page' do
      visit "/#{druid}"
      expect(page).to have_content 'Invariance for perceptual recognition through deep learning'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Abstract/Contents'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Also listed in'
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/10734942'
    end
  end

  context 'file type' do
    let(:druid) { 'gx074xz5520' }

    it 'displays the page' do
      visit "/#{druid}"
      expect(page).to have_content 'Minutes, 2006 May 18'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Abstract/Contents'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Contact information'
      expect(page).to have_content 'Stanford University, Cabinet, Records'
      expect(page).to have_content 'Stanford University. Cabinet, Stanford University--Administration'
      expect(page).to have_link 'Finding aid', href: 'http://www.oac.cdlib.org/findaid/ark:/13030/kt1h4nf2fr/'
      expect(page).to have_link 'archivesref@stanford.edu', href: 'mailto:archivesref@stanford.edu'
    end
  end

  context 'item released to searchworks' do
    let(:druid) { 'cp088pb1682' }

    it 'displays the page' do
      visit "/#{druid}"
      visit '/cp088pb1682'
      expect(page).to have_content 'Atari Competition'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_metadata_section 'Collection'
      expect(page).to have_metadata_section 'Also listed in'
      expect(page).to have_content 'Bay Area video arcades : photographs by Ira Nowinski, 1981-1982'
      expect(page).to have_link 'View other items in this collection in SearchWorks', href: 'https://searchworks.stanford.edu/catalog?f[collection][]=a9685083'
      expect(page).to have_link 'View in SearchWorks', href: 'https://searchworks.stanford.edu/view/cp088pb1682'
    end
  end

  context 'item that is part of collection not released to searchworks' do
    let(:druid) { 'cd027gx5097' }

    it 'lists the collection name and does not link to items in collection' do
      visit "/#{druid}"
      expect(page).to have_content 'Edward Flanders Ricketts papers, 1936-1979 (inclusive), 1936-1947 (bulk)'
      expect(page).to have_no_link 'View other items in this collection in SearchWorks'
    end
  end

  context 'revs object (no version manifest)' do
    let(:druid) { 'tx027jv4938' }

    it 'displays the page without version information' do
      visit "/#{druid}"
      expect(page).to have_content 'IMSA 24 Hours of Daytona'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Bibliographic information'
      expect(page).to have_content 'Revs ID 2012-015GHEW-BW-1984-b4_1.4_0003'
      expect(page).to have_no_content 'You are viewing this version'
      expect(page).to have_no_content 'Each version has a distinct URL, but you can use this PURL to access the latest version.'
    end
  end

  context 'item with a DOI' do
    let(:druid) { 'bb051dp0564' }

    it 'includes altmetrics' do
      visit "/#{druid}"

      expect(page).to have_css 'meta[name="citation_doi"][content="10.25740/bb051dp0564"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_title"][content="The Distinct Impacts of Content Moderation"]', visible: :hidden
      # No publication date so falling back to deposit date
      expect(page).to have_css 'meta[name="citation_publication_date"][content="2022"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_author"][content="Khine, Sandi"]', visible: :hidden
      expect(page).to have_css 'meta[name="citation_author"][content="Navaroli, A. Collier"]', visible: :hidden
    end
  end

  context 'item with Stanford-only location in MODS' do
    let(:druid) { 'yk677wc8843' }

    it 'adds a Stanford-only indicator' do
      visit "/#{druid}"

      expect(page).to have_css '.stanford-only-text', text: 'Stanford only'
      expect(page.find('.stanford-only-text')).to have_sibling('a', text: 'Cambridge Core')
    end
  end

  context 'item with ORCID for some contributors' do
    let(:druid) { 'wm135gp2721' }

    it 'adds ORCID links' do
      visit "/#{druid}"

      expect(page).to have_text(%r{Schroeder, Dustin\s+https://orcid.org/0000-0003-1916-3929\s*})
      orcid_link = page.find_link('https://orcid.org/0000-0003-1916-3929') # text of link
      expect(orcid_link['href']).to eq 'https://orcid.org/0000-0003-1916-3929'
      expect(orcid_link['aria-label']).to eq('view ORCID page for Schroeder, Dustin')

      icons = page.all('img[alt="ORCiD icon"]')
      expect(icons.size).to eq 3
      icons.each { |icon| expect(icon['src']).to eq 'https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png' }
    end
  end

  context 'with an item that is not crawlable' do
    let(:druid) { 'bb000br0025' }

    it 'includes noindex meta tag' do
      visit "/#{druid}"
      expect(page).to have_css 'meta[name="robots"][content="noindex"]', visible: :hidden
    end
  end

  context 'with an item that is crawlable' do
    let(:druid) { 'gb089bd2251' }

    it 'excludes noindex meta tag' do
      visit "/#{druid}"
      expect(page).to have_no_css 'meta[name="robots"][content="noindex"]', visible: :hidden
    end
  end

  context 'with an invalid druid' do
    let(:druid) { 'abcdefg' }

    it '404 with invalid error message' do
      visit "/#{druid}"

      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested does not exist.'
    end
  end

  describe 'legacy object id "ir:rs276tc2764"' do
    let(:druid) { 'rs276tc2764' }

    it 'routed to rs276tc2764' do
      visit "/ir:#{druid}"
      expect(page).to have_current_path("/#{druid}", ignore_query: true)
    end
  end

  describe 'license' do
    let(:druid) { 'wp335yr5649' }

    it 'included in purl page' do
      visit "/#{druid}"
      expect(page).to have_content 'This work is licensed under an Open Data Commons Public Domain Dedication & License 1.0'
    end
  end

  describe 'terms of use' do
    let(:druid) { 'wp335yr5649' }

    it 'included in purl page' do
      visit "/#{druid}"
      expect(page).to have_content 'User agrees that, where applicable, content will not be used to identify or to otherwise infringe the privacy or'
    end
  end

  context 'with an incomplete/unpublished object (not in stacks)' do
    let(:druid) { 'fb123cd4567' }

    it 'gives 404 with unavailable message' do
      visit "/#{druid}"
      expect(page.status_code).to eq(404)
      expect(page).to have_content 'The item you requested is not available.'
      expect(page).to have_content 'This item is in processing or does not exist. If you believe you have reached this page in error, please send Feedback.'
    end

    it 'includes a feedback link that toggled the feedback form', :js do
      allow(Settings.feedback).to receive(:email_to).and_return('feedback@example.com')
      visit "/#{druid}"

      expect(page).to have_no_css('form.feedback-form', visible: :visible)

      within '#main-container' do
        click_on 'Feedback'
      end

      expect(page).to have_css('form.feedback-form', visible: :visible)
    end
  end

  context 'with a version manifest' do
    let(:druid) { 'wp335yr5649' }

    it 'shows the version information panel' do
      visit "/#{druid}"
      expect(page).to have_content 'You are viewing this version'
      expect(page).to have_content 'Each version has a distinct URL, but you can use this PURL to access the latest version.'
    end

    it 'draws the page' do
      visit "/#{druid}/version/3"
      link = page.find('link[rel="alternate"][title="oEmbed Profile"][type="application/json+oembed"]', visible: false)
      expect(link['href']).to eq 'https://embed.stanford.edu/embed.json?url=https%3A%2F%2Fpurl.stanford.edu%2Fwp335yr5649%2Fversion%2F3'
    end
  end

  def have_metadata_section(text)
    have_css 'section h2', text:
  end

  context 'dataset item' do
    let(:druid) { 'wp335yr5649' }

    it 'adds schema.org markup for Datasets' do
      visit "/#{druid}"
      expect(page).to have_css('script[type="application/ld+json"]', text: %r{http://schema.org}, visible: :hidden)
    end
  end
end
