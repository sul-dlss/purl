require 'rails_helper'

RSpec.describe ContentMetadata do
  let(:document) { double(at_xpath: 'rs276tc2764') }
  subject(:content_metadata) { described_class.new(document) }

  describe '#extract_resources' do
    let(:stub_xml) { Nokogiri::XML.parse(fixture).xpath('//resource').first }
    let(:fixture) do
      <<-EOXML
      <resource id="rs276tc2764_2" sequence="2" type="file">
        <label>Cluster Dendrogram 1: Feature Set: the 72 words occurring in the corpus with a mean relative frequency above 1%</label>
        <file id="cluster1.jpg" preserve="yes" publish="yes" shelve="yes" mimetype="image/jpeg" size="116232">
          <checksum type="md5">0cb3d3ab0d16c3660326d27b823023f6</checksum>
          <checksum type="sha1">7d580edae3b3e10880b8d52c8d3393d0edd4abce</checksum>
          <imageData width="1374" height="923"/>
        </file>
      </resource>
      EOXML
    end
    subject(:resource) { content_metadata.extract_resources(stub_xml).first }

    it 'extracts attributes from the xml' do
      expect(resource).to have_attributes id: 'rs276tc2764_2', sequence: 2, type: 'file', label: /Dendrogram 1/
    end

    context 'without a sequence number' do
      let(:fixture) do
        <<-EOXML
          <resource id="bv314fr9257_2" type="main-augmented" objectId="druid:kw044zx5498">
          <attr name="label">Body of dissertation</attr>
          <file id="phd_thesis-augmented.pdf" mimetype="application/pdf" size="8015804"></file>
          </resource>
        EOXML
      end

      it 'provides a default sequence' do
        expect(resource).to have_attributes sequence: Float::INFINITY
      end
    end
  end
end
