# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptionComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:version) { Purl.new(id: druid).version(:head) }

  before do
    render_inline(component)
  end

  context 'with image that has date created' do
    let(:druid) { 'bb000qr5025' }

    it 'displays the component' do
      expect(page).to have_text 'Resource Type'
      expect(page).to have_text 'still image'
      expect(page).to have_text 'Form'
      expect(page).to have_text 'other computer carrier'
      expect(page).to have_text 'Extent'
      expect(page).to have_text '1 optical disc'
      expect(page).to have_text 'Creation date'
      expect(page).to have_text 'May 1988'
      expect(page).to have_text 'Digital origin'
      expect(page).to have_text 'born digital'
    end
  end

  context 'with a document (ETD thesis)' do
    let(:druid) { 'nd387jf5675' }

    it 'displays the component' do
      expect(page).to have_text 'Resource Type'
      expect(page).to have_text 'text'
      expect(page).to have_text 'Form'
      expect(page).to have_text 'electronic; electronic resource; remote'
      expect(page).to have_text 'Extent'
      expect(page).to have_text '1 online resource'
      expect(page).to have_text 'Publication date'
      expect(page).to have_text '2015'
      expect(page).to have_text 'Issuance'
      expect(page).to have_text 'monographic'
      expect(page).to have_text 'Language'
      expect(page).to have_text 'English'
    end
  end

  context 'with a book' do
    let(:druid) { 'bb737zp0787' }

    it 'displays the component' do
      expect(page).to have_text 'Alternative title'
      expect(page).to have_text 'Curate of Cumberworth'
      expect(page).to have_text 'Resource Type'
      expect(page).to have_text 'text'
      expect(page).to have_text 'Form'
      expect(page).to have_text 'print'
      expect(page).to have_text 'Extent'
      expect(page).to have_text 'viii, 412, 40 p. ; 18 cm.'
      expect(page).to have_text 'Imprint'
      expect(page).to have_text 'London'
      expect(page).to have_text 'J. Masters'
      expect(page).to have_text '1859'
      expect(page).to have_text 'Issuance'
      expect(page).to have_text 'monographic'
      expect(page).to have_text 'Language'
      expect(page).to have_text 'English'
    end
  end

  context 'with an image that has digital origin' do
    let(:druid) { 'cp088pb1682' }

    it 'displays the component' do
      expect(page).to have_text 'Digital origin'
      expect(page).to have_text 'reformatted digital'
    end
  end

  context 'with a media file that has form notes' do
    let(:druid) { 'bd699ky6829' }

    it 'includes the notes in the display' do
      expect(page).to have_text 'Type of recording'
      expect(page).to have_text 'analog'
      expect(page).to have_text 'Recording medium'
      expect(page).to have_text 'optical'
    end
  end
end
