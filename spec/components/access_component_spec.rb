# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:purl) { Purl.new(id: druid) }
  let(:druid) { 'bb737zp0787' }
  let(:version) { purl.version(:head) }

  before do
    render_inline(component)
  end

  it 'draws the access information' do
    expect(page).to have_css 'h2', text: 'Access conditions'
    expect(page).to have_content 'Use and reproduction'
    expect(page).to have_content 'Property rights reside with the repository. Literary rights reside with the creators'
    expect(page).to have_content 'Copyright © Stanford University. All Rights Reserved.'
  end

  context 'when use_and_reproduction has line breaks and urls' do
    let(:druid) { 'sn467ty4143' }

    it 'draws them' do
      expect(page).to have_css 'dd p', count: 48
      expect(page).to have_link 'stacemaples@stanford.edu', class: 'su-underline'
      expect(page).to have_link 'https://adminguide.stanford.edu/chapter-6/subchapter-2/policy-6-2-1', class: 'su-underline'
    end
  end
end
