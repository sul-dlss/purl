# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Previewing MODS' do
  context 'with an EEMs object' do
    it 'displays the formatted doc' do
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

      expect(page).to have_css 'dt', text: 'Title'
      expect(page).to have_css 'dd', text: 'Main Title of an Entry : the sub title of the entry'
    end
  end
end
