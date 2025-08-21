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

    it 'renders the json for manifest', skip: 'We need a versioned fixture that has annotations' do
      get '/hx163dc5225/iiif/annotationList/hx163dc5225_9'
      json_body = response.parsed_body
      expect(json_body['@type']).to eq 'sc:AnnotationList'
      expect(json_body['@id']).to eq 'http://www.example.com/hx163dc5225/iiif/annotationList/hx163dc5225_9'
      expect(json_body.dig('resources', 0, '@type')).to eq 'oa:Annotation'
      expect(json_body.dig('resources', 0, 'resource', '@type')).to eq 'cnt:ContentAsText'
    end
  end
end
