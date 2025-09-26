# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'purl/_embed' do
  before { assign(:purl, purl) }

  let(:purl) { Purl.new(id: 'bf973rp9392') }

  it 'displays a purl embed viewer' do
    render
    expect(rendered).to have_css '[data-controller="oembed"]'
  end

  it 'displays a non-javascript fallback' do
    render
    expect(rendered).to have_css 'noscript'
  end

  context 'when a version is specified' do
    let(:version) { PurlVersion.new(id: 'bf973rp9392', head: true, state: 'available', version_id: 2) }

    before do
      assign(:version, version)
      allow_any_instance_of(ActionDispatch::Request).to receive(:path).and_return('/bf973rp9392/version/2') # rubocop:disable RSpec/AnyInstance
      allow(purl).to receive(:version).with(2).and_return(version)
    end

    it 'displays a purl embed viewer with the version' do
      render
      expect(rendered).to have_css '[data-controller="oembed"]'
    end

    it 'displays a non-javascript fallback' do
      render
      expect(rendered).to have_css 'noscript'
    end
  end

  context 'when a version is not specified' do
    let(:version) { PurlVersion.new(id: 'bf973rp9392', head: true, state: 'available', version_id: 1) }

    before do
      allow(purl).to receive(:version).and_return(version)
      allow_any_instance_of(ActionDispatch::Request).to receive(:path).and_return('/bf973rp9392') # rubocop:disable RSpec/AnyInstance
    end

    it 'does not display a purl embed viewer with a version' do
      render
      expect(rendered).to have_css '[data-controller="oembed"]'
    end

    it 'displays a non-javascript fallback' do
      render
      expect(rendered).to have_css 'noscript'
    end
  end
end
