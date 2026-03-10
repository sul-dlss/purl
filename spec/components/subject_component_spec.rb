# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:version) { Purl.new(id: druid).version(:head) }

  before do
    render_inline(component)
  end

  context 'with a precoordinated subject and a name subject' do
    let(:druid) { 'bb000qr5025' }

    it 'displays the contents' do
      expect(page).to have_content 'Jackson, Jesse, 1941-'
      expect(page).to have_content 'Photography'
      expect(page).to have_content 'Presidents > Election'
      expect(page).to have_content 'San Francisco (Calif.)'
    end
  end

  context 'with subjects that have custom displayLabel set' do
    let(:druid) { 'bc798xr9549' }

    it 'honors the displayLabel using separate <tbody> elements' do
      expect(page).to have_css 'tbody tr:nth-child(1) th', text: 'Region'
      expect(page).to have_css 'tbody tr:nth-child(1) td', text: 'Utsang'

      # New <tbody> and <tr> here because the displayLabel changed
      expect(page).to have_css 'tbody tr:nth-child(1) th', text: 'Main topics'
      expect(page).to have_css 'tbody tr:nth-child(1) td', text: 'Invasion and Occupation'
    end

    it 'leaves the other subjects/genres alone' do
      expect(page).to have_css 'tbody tr:nth-child(1) th', text: 'Genre'
      expect(page).to have_css 'tbody tr:nth-child(1) td', text: 'Filmed interviews'

      # Same <tbody> as the previous subject, since these are genres with no displayLabel
      expect(page).to have_css 'tbody tr:nth-child(2) th', text: 'Genre'
      expect(page).to have_css 'tbody tr:nth-child(2) td', text: 'Interview transcripts'
    end
  end
end
