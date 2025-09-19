# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:version) { PurlResource.new(id: druid).version(:head) }

  before do
    render_inline(component)
  end

  context 'with a name subject' do
    let(:druid) { 'tb420df0840' }

    it 'displays the contents' do
      expect(page).to have_content 'Callas, Maria, 1923-1977'
      expect(page).to have_content 'Opera'
    end
  end
end
