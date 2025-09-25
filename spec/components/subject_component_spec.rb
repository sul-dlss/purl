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
end
