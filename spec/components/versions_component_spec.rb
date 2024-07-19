# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionsComponent, type: :component do
  let(:instance) { described_class.new(purl:, version:) }
  let(:purl) { instance_double(PurlResource, druid: 'km993dd6050') }
  let(:version) { instance_double(PurlVersion, updated_at: DateTime.parse('2024-07-11 19:30:58 UTC')) }

  it 'renders the version table' do
    render_inline(instance)
    expect(page).to have_css '.text-primary', text: 'Versions'
    expect(page).to have_css 'p', text: 'Each version has a distinct URL, but you can use this PURL to access the latest version.'
    expect(page).to have_link 'https://purl.stanford.edu/km993dd6050'
  end
end
