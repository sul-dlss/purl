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
      expect(page).to have_text 'Jackson, Jesse, 1941-'
      expect(page).to have_text 'Photography'
      expect(page).to have_text 'Presidents > Election'
      expect(page).to have_text 'San Francisco (Calif.)'
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

  context 'with parallel subject values' do
    let(:version) { instance_double(PurlVersion, cocina_display:) }
    let(:cocina_display) do
      CocinaDisplay::CocinaRecord.new(
        'description' => {
          'subject' => [
            {
              'parallelValue' => [
                { 'value' => '로동자', 'status' => 'primary', 'valueLanguage' => { 'code' => 'kor' } },
                { 'value' => 'Nodongja', 'type' => 'transliterated', 'valueLanguage' => { 'code' => 'kor' } }
              ]
            }
          ]
        }
      )
    end

    it 'displays every parallel value' do
      expect(page).to have_text '로동자'
      expect(page).to have_text 'Nodongja'
    end
  end
end
