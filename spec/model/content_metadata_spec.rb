require 'rails_helper'

RSpec.describe ContentMetadata do
  subject(:content_metadata) { described_class.new(document) }

  describe '#resources' do
    let(:document) { Nokogiri::XML(fixture).root }
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
    subject { content_metadata.resources }

    it { is_expected.to all(be_kind_of ResourceFile) }
  end
end
