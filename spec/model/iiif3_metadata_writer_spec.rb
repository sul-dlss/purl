require 'rails_helper'

RSpec.describe Iiif3MetadataWriter do
  let(:xml) do
    <<~XML
      <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
      <dc:title>H2 title field</dc:title>
      <dc:contributor>Author, First (authoraut)</dc:contributor>
      <dc:contributor>contributor, Second (compilercom)</dc:contributor>
      <dc:type>Text</dc:type>
      <dc:type>Policy brief</dc:type>
      <dc:type>Text</dc:type>
      <dc:description>This is the abstract field</dc:description>
      <dc:description type="preferred citation">This is the citation</dc:description>
      <dc:subject>keyword</dc:subject>
      <dc:date>2025-02-20</dc:date>
      <dc:date>2024-04-05</dc:date>
      <dc:date>2025-01-03</dc:date>
      <dc:identifier>https://sul-purl-stage.stanford.edu/zw438wf4318</dc:identifier>
      <dc:description type="contact" displayLabel="Contact">bergeraj@stanford.edu</dc:description>
      <dc:relation type="url" href="https://argo-stage.stanford.edu/view/druid:gm804vr8973">Just a related link</dc:relation>
      <dc:relation type="collection">viewer testing</dc:relation>
      <dc:identifier>doi: https://doi.org/10.80343/zw438wf4318</dc:identifier>
      </oai_dc:dc>
    XML
  end
  let(:ng_doc) { Nokogiri::XML(xml) }
  let(:metadata_writer) do
    described_class.new(dc_nodes: ng_doc.xpath('//oai_dc:dc/*', 'oai_dc' => IiifPresentationManifest::OAI_DC_SCHEMA),
                        published_dates: [],
                        url: 'https://example.com')
  end

  describe '#write' do
    subject(:metadata) { metadata_writer.write }

    context 'with relation[@type="url"]' do
      it 'filters out the url value' do
        expect(metadata.find { it['label'][:en] == ['Relation'] }['value'][:en]).to eq ['viewer testing']
      end
    end

    context 'with description[@displayLabel]' do
      it 'filters uses the displayLabel value' do
        expect(metadata.find { it['label'][:en] == ['Description'] }['value'][:en]).not_to include 'bergeraj@stanford.edu'
        expect(metadata.find { it['label'][:en] == ['Contact'] }['value'][:en]).to eq ['bergeraj@stanford.edu']
      end
    end

    context 'with description[@type]' do
      it 'filters uses the type value' do
        expect(metadata.find { it['label'][:en] == ['Description'] }['value'][:en]).not_to include 'This is the citation'
        expect(metadata.find { it['label'][:en] == ['Preferred citation'] }['value'][:en]).to eq ['This is the citation']
      end
    end
  end
end
