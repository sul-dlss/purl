# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbedComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:version) { instance_double(PurlVersion, embeddable?: embeddable) }

  before do
    render_inline(component)
  end

  context 'when embeddable' do
    let(:embeddable) { true }

    it 'displays the viewer' do
      expect(page).to have_css '[data-controller="oembed"]'
      expect(page).to have_css 'noscript'
    end
  end

  context 'when not embeddable' do
    let(:embeddable) { false }

    it 'displays nothing' do
      expect(page).to have_no_css '*'
    end
  end
end
