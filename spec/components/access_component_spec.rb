# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:purl) { PurlResource.new(id: druid) }
  let(:druid) { 'bb737zp0787' }
  let(:version) { purl.version(:head) }

  before do
    render_inline(component)
  end

  it 'draws the access information' do
    expect(page).to have_css 'h2', text: 'Access conditions'
    expect(page).to have_content 'Use and Reproduction'
    expect(page).to have_content 'Property rights reside with the repository. Literary rights reside with the creators'
    expect(page).to have_content 'Copyright © Stanford University. All Rights Reserved.'
  end
end
