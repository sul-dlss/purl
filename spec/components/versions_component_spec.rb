# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionsComponent, type: :component do
  let(:instance) { described_class.new(purl:, version: purl.version(:head)) }
  let(:purl) { PurlResource.new(id: 'wp335yr5649') }

  before { render_inline(instance) }

  it 'renders the version table' do
    expect(page).to have_css '.section-header', text: 'Versions'
    expect(page).to have_css 'p', text: 'Each version has a distinct URL, but you can use this PURL to access the latest version.'
    expect(page).to have_link 'https://purl.stanford.edu/wp335yr5649'

    expect(page).to have_css 'table tr', count: 4
  end
end
