# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::BodyComponent, type: :component do
  subject(:component) { described_class.new(version:) }

  let(:version) { PurlResource.new(id: druid).version(:head) }

  before do
    render_inline(component)
  end

  describe 'Abstract/Contents' do
    context 'with an abstract' do
      let(:druid) { 'wm135gp2721' }

      it 'displays the abstract' do
        expect(page).to have_content 'We present an ice-penetrating radar dataset acquired over the Greenland ice sheet by aircraft'
      end
    end

    context 'with a note with no type, but with Abstract in the displayLabel' do
      let(:druid) { 'nd387jf5675' }

      it 'displays the abstract' do
        expect(page).to have_content 'The brain implements recognition systems with incredible competence.'
      end
    end

    context 'with contents' do
      let(:druid) { 'tb420df0840' }

      it 'displays the contents' do
        expect(page).to have_content 'Complete scans of box 1 folder 1 of from the Robert Baxter collection.'
      end
    end
  end
end
