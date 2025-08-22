require 'rails_helper'

RSpec.describe 'purl', type: :feature do
  describe 'manifest' do
    context 'v2' do
      it 'renders the json for a book' do
        visit '/bc854fy5899/iiif/manifest'
        json_body = JSON.parse(page.body)
        expect(json_body['label']).to eq 'Cambridge, Corpus Christi College, MS 296: John Wyclif and his followers, Tracts in Middle English'
        expect(json_body['metadata'].length).to eq 48
      end

      it 'renders the iiif v3 json for a file object' do
        visit '/gx074xz5520/iiif/manifest'
        json_body = JSON.parse(page.body)
        expect(json_body['@context']).to include('http://iiif.io/api/presentation/3/context.json')
        expect(json_body['id']).to eq 'http://www.example.com/gx074xz5520/iiif/manifest'
        expect(json_body['label']['en']).to eq ['Minutes, 2006 May 18']
      end
    end

    context 'v3' do
      context 'on a book' do
        it 'renders the json for manifest' do
          visit '/bc854fy5899/iiif3/manifest'
          json_body = JSON.parse(page.body)
          expect(json_body['label']['en'].first).to eq 'Cambridge, Corpus Christi College, MS 296: John Wyclif and his followers, Tracts in Middle English'
          expect(json_body['metadata'].length).to eq 11
        end
      end

      context 'on a collection' do
        it 'renders a iiif v3 collection manifest' do
          visit '/sk882gx0113/iiif/manifest'

          json_body = JSON.parse(page.body)
          expect(json_body['type']).to eq 'Collection'
        end
      end
    end
  end

  describe 'annotation' do
    context 'v2' do
      it 'renders the json for a book' do
        visit '/bc854fy5899/iiif/annotation/cocina-fileSet-bc854fy5899-bc854fy5899_1'
        json_body = JSON.parse(page.body)
        expect(json_body['motivation']).to eq('sc:painting')
      end

      it 'renders nil for a file object' do
        visit '/wp335yr5649/iiif/annotation/bc854fy5899_fdsa'
        expect(page.status_code).to eq(404)
      end
    end

    context 'v3' do
      it 'renders the json for a book' do
        visit '/bc854fy5899/iiif3/annotation/cocina-fileSet-bc854fy5899-bc854fy5899_1'
        json_body = JSON.parse(page.body)
        expect(json_body['motivation']).to eq('painting')
      end

      it 'renders nil for a file object' do
        visit '/wp335yr5649/iiif3/annotation/bc854fy5899_fdsa'
        expect(page.status_code).to eq(404)
      end
    end
  end
end
