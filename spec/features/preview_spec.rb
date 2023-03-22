require 'rails_helper'

RSpec.describe 'Previewing MODS' do
  context 'with an EEMs object' do
    it 'works' do
      visit '/preview'
      fill_in :mods, visible: false, with: <<-EOXML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <titleInfo>
          <title>Main Title of an Entry</title>
          <subTitle>the sub title of the entry</subTitle>
        </titleInfo>
      </mods>
      EOXML

      click_on 'Show me the MODS!'

      expect(page).to have_selector 'dt', text: 'Title'
      expect(page).to have_selector 'dd', text: 'Main Title of an Entry : the sub title of the entry'
    end
  end
end
