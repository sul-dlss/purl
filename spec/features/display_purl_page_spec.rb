# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Displaying the PURL page' do
  context 'with a map' do
    let(:druid) { 'rp193xx6845' }

    it 'displays the page' do
      visit "/#{druid}"
      expect(page).to have_content '[Plates to Allgemeine auf Geschichte und Erfahrung gegründete theoretisch-practische Wasserbaukunst.]'
      expect(page).to have_metadata_section 'Access conditions'
      expect(page).to have_metadata_section 'Description'
      expect(page).to have_metadata_section 'Contributors'
      expect(page).to have_metadata_section 'Subjects'
      expect(page).to have_link 'rumseymapcenter@stanford.edu', href: 'mailto:rumseymapcenter@stanford.edu'
    end
  end

  context 'with a file type' do
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

  context 'with an image that is released to searchworks' do
    let(:druid) { 'cp088pb1682' }

    it 'displays the page' do
      visit "/#{druid}"
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

  context 'with an book that is part of collection not released to searchworks' do
    let(:druid) { 'cd027gx5097' }

    it 'lists the collection name and does not link to items in collection' do
      visit "/#{druid}"
      expect(page).to have_content 'Edward Flanders Ricketts papers, 1936-1979 (inclusive), 1936-1947 (bulk)'
      expect(page).to have_no_link 'View other items in this collection in SearchWorks'
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

  context 'with an incomplete/unpublished object (not in stacks)' do
    let(:druid) { 'fb123cd4567' }

    it 'gives unavailable message and a feedback form', :js do
      visit "/#{druid}"
      expect(page).to have_content 'The item you requested is not available.'
      expect(page).to have_content 'This item is in processing or does not exist. If you believe you have reached this page in error, please send Feedback.'

      expect(page).to have_no_css('form.feedback-form', visible: :visible)

      within '#main-container' do
        click_on 'Feedback'
      end

      expect(page).to have_css('form.feedback-form', visible: :visible)
    end
  end

  context 'with more than one version' do
    let(:druid) { 'zb733jx3137' }

    it 'shows the version information panel' do
      visit "/#{druid}"
      expect(page).to have_content 'You are viewing this version'
      expect(page).to have_content 'Each version has a distinct URL, but you can use this PURL to access the latest version.'
    end
  end

  def have_metadata_section(text)
    have_css 'section h2', text:
  end
end
