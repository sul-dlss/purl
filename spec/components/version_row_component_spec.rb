# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionRowComponent, type: :component do
  let(:purl) { PurlResource.new(id: 'wp335yr5649') }

  before { render_inline(instance) }

  context 'when rendering not the requested version' do
    let(:instance) { described_class.new(version: purl.version(:head), requested_version: purl.version(2)) }

    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 4'
      expect(page).to have_css 'td', text: 'Jul 24, 2024'
      expect(page).to have_link 'View', href: '/wp335yr5649/version/4'
      expect(page).to have_css '[data-clipboard-url-value="http://test.host/wp335yr5649/version/4"]', text: 'Copy URL'
    end
  end

  context 'when rendering the requested version' do
    let(:instance) { described_class.new(version: purl.version(2), requested_version: purl.version(2)) }

    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 2'
      expect(page).to have_css 'td', text: 'Jul 22, 2024'
      expect(page).to have_css 'td', text: 'You are viewing this version'
      expect(page).to have_css '[data-clipboard-url-value="http://test.host/wp335yr5649/version/2"]', text: 'Copy URL'
    end
  end

  context 'when rendering a withdrawn version' do
    let(:instance) { described_class.new(version: purl.version(3), requested_version: purl.version(2)) }

    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 3'
      expect(page).to have_css 'td', text: 'Jul 23, 2024'
      expect(page).to have_css 'td', text: 'Withdrawn'
    end
  end

  context 'when rendering a permanently withdrawn version' do
    let(:instance) { described_class.new(version: purl.version(1), requested_version: purl.version(2)) }

    it 'renders the version row' do
      expect(page).to have_css 'th', text: 'Version 1'
      expect(page).to have_css 'td', text: 'Permanently withdrawn'
    end
  end
end
