# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionRowComponent, type: :component do
  let(:version_id) { 4 }
  let(:updated_at) { Date.parse('2024-07-24') }
  let(:state) { 'available' }
  let(:version) { PurlVersion.new(version_id:, id: 'zb733jx3137', state:, updated_at:) }
  let(:requested_version) { instance_double PurlVersion, version_id: 2 }
  let(:instance) { described_class.new(version:, requested_version:) }

  before { render_inline(instance) }

  context 'when rendering not the requested version' do
    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 4'
      expect(page).to have_css 'td', text: 'Jul 24, 2024'
      expect(page).to have_link 'View', href: '/zb733jx3137/version/4'
      expect(page).to have_css '[data-clipboard-url-value="http://purl.stanford.edu/zb733jx3137/version/4"]', text: 'Copy URL'
    end
  end

  context 'when rendering the requested version' do
    let(:version_id) { 2 }
    let(:updated_at) { Date.parse('2024-07-22') }

    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 2'
      expect(page).to have_css 'td', text: 'Jul 22, 2024'
      expect(page).to have_css 'td', text: 'You are viewing this version'
      expect(page).to have_css '[data-clipboard-url-value="http://purl.stanford.edu/zb733jx3137/version/2"]', text: 'Copy URL'
    end
  end

  context 'when rendering a withdrawn version' do
    let(:version_id) { 3 }
    let(:updated_at) { Date.parse('2024-07-23') }
    let(:state) { 'withdrawn' }

    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 3'
      expect(page).to have_css 'td', text: 'Jul 23, 2024'
      expect(page).to have_css 'td', text: 'Withdrawn'
    end
  end

  context 'when rendering a permanently withdrawn version' do
    let(:version_id) { 1 }
    let(:updated_at) { Date.parse('2024-07-21') }
    let(:state) { 'permanently withdrawn' }

    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 1'
      expect(page).to have_css 'td', text: 'Permanently withdrawn'
    end
  end
end
