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
  end

  it 'displays versions as expected' do
    expect(page.text).to match(/Version 4\s+Jul 24, 2024\s+You are viewing this version | Copy URL/)
    expect(page.text).to match(/Version 3\s+Jul 23, 2024\s+Withdrawn/)
    expect(page.text).to match(/Version 2\s+Jul 22, 2024\s+View | Copy URL/)
    expect(page.text).to match(/Version 1\s+Permanently withdrawn/)
  end
end
