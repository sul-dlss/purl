# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptionComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:version) { PurlResource.new(id: druid).version(:head) }

  before do
    render_inline(component)
  end

  context 'with a document (ETD thesis)' do
    let(:druid) { 'nd387jf5675' }

    it 'displays the component' do
      expect(page).to have_content 'Form'
      expect(page).to have_content 'electronic; electronic resource; remote'
      expect(page).to have_content 'Extent'
      expect(page).to have_content '1 online resource'
      expect(page).to have_content 'Publication date'
      expect(page).to have_content '2015'
      expect(page).to have_content 'Issuance'
      expect(page).to have_content 'monographic'
      expect(page).to have_content 'Language'
      expect(page).to have_content 'English'
    end
  end
end
