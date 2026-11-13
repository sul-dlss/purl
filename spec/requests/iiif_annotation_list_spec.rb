# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IIIF Annotation List' do
  let(:body) do
    <<~JSON
      {"@type":"oa:Annotation","motivation":"sc:painting","on":"https://purl.stanford.edu/hx163dc5225/iiif/canvas/hx163dc5225_9#xywh=0,0,2035,2531","resource":{"@id":"https://fromthepage.com/gkhalsa/19th-century-steinbeck-family-papers/a-sketch-of-the-life-of-john-a-steinbeck-the-dickson-family-and-the-jewish-mission-in-palestine-asia-approximately-30pp-233-c-1917/annotation/1264421/html/transcription","@type":"cnt:ContentAsText","format":"text/html","chars":"<p>before going out in the morning. But the <br/>\\nstepmother would not allow the children to <br/>\\nhave anything. However the affectionate <br/>\\n<a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51050&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51050' title='Peter GrossSteinbeck Sr.'>father</a> pitied poor little <a data-tooltip='https://fromthepage.com/article/tooltip?article_id=50914&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=50914' title='John Adolph Steinbeck'>John</a> out <br/>\\nin the early dawn cold tending the cows <br/>\\nand if the thrifty stepmother was not look-<br/>\\ning he would slip a slice of bread into <br/>\\nhis coat pocket for little <a data-tooltip='https://fromthepage.com/article/tooltip?article_id=50914&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=50914' title='John Adolph Steinbeck'>John</a>.(she only <br/>\\nlived a few years). After milking the cows <br/>\\n<a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51006&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51006' title='Katherine Steinbeck Theil'>Katherine</a> cut the clover, no matter how wet <br/>\\nand cold it was. And <a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51005&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51005' title='Peter GrossSteinbeck Jr.'>Peter</a> tied it in <br/>\\nbundles tied with strong bands. Put it in <br/>\\na cart and hauled it to the barn.</p>\\n\\n<p><a data-tooltip='https://fromthepage.com/article/tooltip?article_id=51006&amp;collection_id=19th-century-steinbeck-family-papers' href='https://fromthepage.com/article/show?article_id=51006' title='Katherine Steinbeck Theil'>Katherine</a> put straw in the cows stalls and <br/>\\nonce a week gave them a througher cleaning <br/>\\nout. At eight oclock the workers gathered <br/>\\nfor breakfast consisting of coffee potatoes <br/>\\nand bread and butter.</p>\\n\\n<p>Bread was baked once a month in a </p>","annotatedBy":[{"name":"Kireis"},{"name":"gkhalsa"}]}}\n
    JSON
  end
  let(:stacks_response) { instance_double(Faraday::Response, body: body.to_s) }

  context 'when using v2' do
    before { allow(Faraday).to receive(:get).and_return(stacks_response) }

    it 'renders the json for manifest' do
      get '/hx163dc5225/iiif/annotationList/cocina-fileSet-hx163dc5225-hx163dc5225_9'
      json_body = response.parsed_body
      expect(json_body['@type']).to eq 'sc:AnnotationList'
      expect(json_body['@id']).to eq 'http://www.example.com/hx163dc5225/iiif/annotationList/cocina-fileSet-hx163dc5225-hx163dc5225_9'
      expect(json_body.dig('resources', 0, '@type')).to eq 'oa:Annotation'
      expect(json_body.dig('resources', 0, 'resource', '@type')).to eq 'cnt:ContentAsText'
    end
  end

  context 'when using v3' do
    context 'with georeference annotations' do
      let(:canvas_id) { 'https://purl.stanford.edu/bb013fz9675/iiif/canvas/cocina-fileSet-bb013fz9675-bb013fz9675_1' }
      let(:georeference_annotations) do
        [
          {
            id: 'https://annotations.allmaps.org/maps/00c41531f101722f',
            type: 'Annotation',
            '@context': ['http://iiif.io/api/extension/georef/1/context.json', 'http://iiif.io/api/presentation/3/context.json'],
            motivation: 'georeferencing',
            target: {
              type: 'SpecificResource',
              source: { id: canvas_id, type: 'Canvas' },
              selector: { type: 'SvgSelector', value: '<svg width="24580" height="16174"><polygon points="1506,1697 1506,13464 21769,13454" /></svg>' }
            },
            body: {
              type: 'FeatureCollection',
              transformation: { type: 'polynomial', options: { order: 1 } },
              features: [{ type: 'Feature', properties: { resourceCoords: [1830, 959] }, geometry: { type: 'Point', coordinates: [-78.44, 8.05] } }]
            }
          },
          {
            id: 'https://annotations.allmaps.org/maps/1b2f3e4d5c6a7980',
            type: 'Annotation',
            motivation: 'georeferencing',
            target: canvas_id,
            body: { type: 'FeatureCollection', features: [] }
          }
        ]
      end
      let(:body) do
        {
          id: 'https://annotations.allmaps.org/images/a771c1dd3e9ddc0f',
          type: 'AnnotationPage',
          '@context': 'http://www.w3.org/ns/anno.jsonld',
          items: georeference_annotations
        }.to_json
      end

      before { allow(Faraday).to receive(:get).and_return(stacks_response) }

      it 'serves the annotations from the file directly, unmodified' do
        get '/bb013fz9675/iiif3/annotations/cocina-fileSet-bb013fz9675-bb013fz9675_1'
        json_body = response.parsed_body

        expect(Faraday).to have_received(:get).with('https://stacks.stanford.edu/file/bb013fz9675/bb013fz9675_0001.json')
        expect(json_body['@context']).to eq ['http://www.w3.org/ns/anno.jsonld', 'http://iiif.io/api/presentation/3/context.json']
        expect(json_body['type']).to eq 'AnnotationPage'
        expect(json_body['id']).to eq 'http://www.example.com/bb013fz9675/iiif3/annotations/cocina-fileSet-bb013fz9675-bb013fz9675_1'
        expect(json_body['items']).to eq georeference_annotations.as_json
      end

      context 'when in UAT' do
        before do
          allow(Settings.embed).to receive(:url).and_return('https://sul-purl-uat.stanford.edu/%<druid>s')
        end

        it 'rewrites prod canvas URLs to match UAT environment' do
          get '/bb013fz9675/iiif3/annotations/cocina-fileSet-bb013fz9675-bb013fz9675_1'
          json_body = response.parsed_body

          expect(json_body.dig('items', 0, 'target', 'source', 'id')).to eq 'https://sul-purl-uat.stanford.edu/bb013fz9675/iiif/canvas/cocina-fileSet-bb013fz9675-bb013fz9675_1'
        end

        it 'leaves other URLs alone' do
          get '/bb013fz9675/iiif3/annotations/cocina-fileSet-bb013fz9675-bb013fz9675_1'
          json_body = response.parsed_body

          expect(json_body.dig('items', 0, 'id')).to eq 'https://annotations.allmaps.org/maps/00c41531f101722f'
        end
      end
    end

    context 'with transcription annotations' do
      let(:annotations) do
        [
          {
            id: 'https://example.com/annotations/1',
            type: 'Annotation',
            motivation: 'supplementing',
            target: 'https://purl.stanford.edu/hx163dc5225/iiif/canvas/cocina-fileSet-hx163dc5225-hx163dc5225_9#xywh=0,0,2035,2531',
            body: { type: 'TextualBody', format: 'text/html', value: '<p>before going out in the morning.</p>' }
          }
        ]
      end
      let(:body) { { id: 'https://example.com/annotations', type: 'AnnotationPage', items: annotations }.to_json }

      before { allow(Faraday).to receive(:get).and_return(stacks_response) }

      it 'serves the annotations from the file directly, unmodified' do
        get '/hx163dc5225/iiif3/annotations/cocina-fileSet-hx163dc5225-hx163dc5225_9'
        json_body = response.parsed_body

        expect(json_body['type']).to eq 'AnnotationPage'
        expect(json_body['id']).to eq 'http://www.example.com/hx163dc5225/iiif3/annotations/cocina-fileSet-hx163dc5225-hx163dc5225_9'
        expect(json_body['items']).to eq annotations.as_json
      end
    end
  end
end
