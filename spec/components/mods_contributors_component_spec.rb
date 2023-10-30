# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModsContributorsComponent, type: :component do
  it 'displays nothing if no roles_with_names are present' do

  end

  context 'when roles_with_names from mods_display is present' do
    let(:html) { render_inline(described_class.new(roles_with_contributors: { 'author' => ['John Doe', 'Eva'] })).to_html }

    it 'renders the section with id contributors' do
      expect(html.css('.section')).to be_truthy
      expect(html.css('#contributors')).to be_truthy
    end

    it 'renders the section heading' do
      expect(
        html.css('h2').to_html
      ).to include('Creators/Contributors')
    end

    it 'renders the role' do
      expect(html.css('.section-body').to_html).to include('<dl>\s+<dt>Author<dt>')
    end

    it 'renders each name for the role' do
      expect(html.css('.section-body').to_html).to include('<dd>John Doe<dd>')
      expect(html.css('.section-body').to_html).to include('<dd>Eva<dd>\s+</dl>')
    end
  end
end
