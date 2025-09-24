# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::Description::RelatedResourcesFieldComponent, type: :component do
  subject(:component) { described_class.new(related_resources_field:) }

  let(:values) do
    PurlResource.new(id: druid).version(:head).cocina_display.related_resource_display_data
  end

  let(:related_resources_field) { values.first }

  before do
    render_inline(component)
  end

  context 'with an item with labelled finding aid link' do
    let(:druid) { 'gx074xz5520' }

    it 'renders the labelled finding aid link' do
      expect(rendered_content).to have_link('Finding aid', href: 'http://www.oac.cdlib.org/findaid/ark:/13030/kt1h4nf2fr/')
    end
  end

  context 'with a parker item with complex citation related resources' do
    let(:druid) { 'vb856kp8798' }

    context 'with a link resource' do
      let(:related_resources_field) { values.first }

      it 'renders links that were re-categorized using displayLabel' do
        expect(rendered_content).to have_css('th', text: 'Downloadable James Catalogue Record')
        expect(rendered_content).to have_link(href: 'https://stacks.stanford.edu/file/druid:qr266kr9896/MS_2II.pdf')
      end
    end

    context 'with a non-link resource' do
      let(:related_resources_field) { values.third }

      it 'renders the nested metadata as a <dl>' do
        expect(rendered_content).to have_css('dl.related-item')
        expect(rendered_content).to have_css('dt', text: 'Title')
        expect(rendered_content).to have_css('dd', text: 'The Bury Bible. 122r-241v')
        expect(rendered_content).to have_css('dt', text: 'Rubric')
        expect(rendered_content).to have_css('dd', text: '(128v) Explicit liber Josue Bennun habet versus I DCCC L')
      end
    end
  end
end
