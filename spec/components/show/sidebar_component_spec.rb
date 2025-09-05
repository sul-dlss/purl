# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::SidebarComponent, type: :component do
  subject(:component) { described_class.new(purl:, version:) }

  let(:purl) { PurlResource.new(id: druid) }
  let(:version) { purl.version(:head) }

  before do
    render_inline(component)
  end

  context 'with a license' do
    let(:druid) { 'zb733jx3137' }

    it 'included in purl page' do
      expect(page).to have_content 'This work is licensed under an Open Data Commons Public Domain Dedication & License 1.0'
    end
  end

  context 'with terms of use' do
    let(:druid) { 'wm135gp2721' }

    it 'included in purl page' do
      expect(page).to have_content 'User agrees that, where applicable, content will not be used to identify or to otherwise infringe the privacy or'
    end
  end
end
