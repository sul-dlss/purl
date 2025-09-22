# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurlVersion do
  subject(:instance) { described_class.new(id: druid, version_id:, head: head_version, state:, updated_at:, resource_retriever:) }

  let(:head_version) { nil }
  let(:druid) { nil }
  let(:version_id) { '1' }
  let(:updated_at) { '2024-07-29T11:28:33-07:00' }
  let(:state) { 'available' }
  let(:resource_retriever) { VersionedResourceRetriever.new(druid:, version_id:) }

  describe '#version_id=' do
    it 'is normalized to an integer' do
      expect(instance.version_id).to eq(1)
    end
  end

  describe '#updated_at=' do
    it 'is normalized to a datetime' do
      expect(instance.updated_at).to be_a(DateTime)
    end
  end

  describe '#head?' do
    context 'with the head version' do
      let(:head_version) { true }

      it 'returns true' do
        expect(instance).to be_head
      end
    end

    context 'with a non-head version' do
      let(:head_version) { false }

      it 'returns false' do
        expect(instance).not_to be_head
      end
    end
  end

  describe '#withdrawn?' do
    context 'with a withdrawn version' do
      let(:state) { 'withdrawn' }

      it 'returns true' do
        expect(instance).to be_withdrawn
      end
    end

    context 'with a non-withdrawn version' do
      it 'returns false' do
        expect(instance).not_to be_withdrawn
      end
    end
  end

  describe 'resource methods' do
    describe '#mods' do
      subject(:mods) { instance.mods }

      let(:body) do
        <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
              <dc:title>The title from the DC</dc:title>
            </oai_dc:dc>
            <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
              <titleInfo>
                <title>The title from the MODS.</title>
              </titleInfo>
            </mods>
          </publicObject>
        XML
      end

      before do
        allow(resource_retriever).to receive(:public_xml_body).and_return(body)
      end

      it 'checks if the request succeeded' do
        expect(mods).to be_present
      end
    end

    context 'when layout is versioned' do
      let(:druid) { 'zb733jx3137' }
      let(:head_version) { true }
      let(:version_id) { '3' }
      let(:resource_retriever) { VersionedResourceRetriever.new(druid:, version_id:) }

      describe '#public_xml' do
        it 'retrieves public XML from versioned layout' do
          expect(instance.public_xml.title).to eq(
            'Testing versioning issue with the review workflow in the new application again'
          )
        end
      end
    end
  end

  describe '#embeddable?' do
    subject { instance.embeddable? }

    before do
      allow(resource_retriever).to receive(:cocina_body).and_return(cocina)
    end

    context 'with resources' do
      let(:cocina) do
        <<~COCINA
          {
            "structural":{
              "contains":[
                {
                  "type": "https://cocina.sul.stanford.edu/models/resources/page",
                  "structural":{
                    "contains":[
                      {
                        "type": "https://cocina.sul.stanford.edu/models/resources/file",
                        "filename": "bb737zp0787_00_0002.jp2",
                        "hasMimeType": "image/jp2",
                        "access": {
                            "view": "world",
                            "download": "world"
                        }
                      }
                    ]
                  }
                }
              ]
            }
          }
        COCINA
      end

      it { is_expected.to be true }
    end

    context 'without resources' do
      let(:cocina) do
        <<~COCINA
          {}
        COCINA
      end

      it { is_expected.to be false }
    end
  end

  describe '#description' do
    let(:body) do
      <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <publicObject>
          <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <abstract>The abstract from the MODS.</abstract>
          </mods>
        </publicObject>
      XML
    end

    before do
      allow(resource_retriever).to receive(:public_xml_body).and_return(body)
    end

    it 'extracts a description from the MODS abstract' do
      expect(instance.description).to eq 'The abstract from the MODS.'
    end
  end

  describe '#ready?' do
    before do
      allow(resource_retriever).to receive(:public_xml_body).and_return('ok')
    end

    it 'is ready if the public xml is present' do
      expect(instance).to be_ready
    end
  end

  describe '#cache_key' do
    subject(:instance) { described_class.new(id: 'oo000oo0000', version_id: 1) }

    it 'namespaces the purl resource' do
      expect(instance.cache_key).to eq 'purl_resource/druid:oo000oo0000/1'
    end
  end

  describe '#representative_thumbnail' do
    subject(:thumbnail) { instance.representative_thumbnail }

    let(:druid) { 'bb737zp0787' }

    before do
      allow(resource_retriever).to receive_messages(cocina_body:, public_xml_body: xml)
    end

    context 'when a thumbnail is present' do
      let(:cocina_body) do
        <<~COCINA
          {
            "structural": {
              "contains": [
                  {
                      "type": "https://cocina.sul.stanford.edu/models/resources/page",
                      "externalIdentifier": "https://cocina.sul.stanford.edu/fileSet/bb737zp0787-bb737zp0787_1",
                      "label": "Page 1",
                      "version": 3,
                      "structural": {
                          "contains": [
                              {
                                  "type": "https://cocina.sul.stanford.edu/models/file",
                                  "externalIdentifier": "https://cocina.sul.stanford.edu/file/bb737zp0787-bb737zp0787_1/bb737zp0787_00_0002.jp2",
                                  "label": "bb737zp0787_00_0002.jp2",
                                  "filename": "bb737zp0787_00_0002.jp2",
                                  "size": 493809,
                                  "version": 3,
                                  "hasMimeType": "image/jp2",
                                  "hasMessageDigests": [
                                      {
                                          "type": "sha1",
                                          "digest": "a3168aa033d335294298a21f8b1b1063e8a40867"
                                      },
                                      {
                                          "type": "md5",
                                          "digest": "e4f2099fd55d7be19906872e2ae015bd"
                                      }
                                  ],
                                  "access": {
                                      "view": "world",
                                      "download": "world",
                                      "controlledDigitalLending": false
                                  },
                                  "administrative": {
                                      "publish": true,
                                      "sdrPreserve": false,
                                      "shelve": true
                                  },
                                  "presentation": {
                                      "height": 1901,
                                      "width": 1361
                                  }
                              }
                          ]
                      }
                  }
              ]
            }
          }
        COCINA
      end

      let(:xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <contentMetadata type="book" objectId="druid:bb737zp0787">
            <resource id="cocina-fileSet-bb737zp0787-bb737zp0787_1" sequence="1" type="page">
              <label>Page 1</label>
              <file id="bb737zp0787_00_0002.jp2" mimetype="image/jp2" size="493809" publish="yes" shelve="yes" preserve="no">
                <checksum type="sha1">a3168aa033d335294298a21f8b1b1063e8a40867</checksum>
                <checksum type="md5">e4f2099fd55d7be19906872e2ae015bd</checksum>
                <imageData height="1901" width="1361"/>
              </file>
            </resource>
            </contentMetadata>
            <rightsMetadata>
              <access type="discover">
                <machine>
                  <world/>
                </machine>
              </access>
              <access type="read">
                <machine>
                  <world/>
                </machine>
              </access>
            </rightsMetadata>
          </publicObject>
        XML
      end

      it 'is the representative thumbnail for the object' do
        expect(thumbnail).to eq 'https://stacks.stanford.edu/image/iiif/bb737zp0787%2Fbb737zp0787_00_0002/full/!400,400/0/default.jpg'
      end
    end

    context 'when no thumbnail is present' do
      let(:xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <contentMetadata type="book">
            </contentMetadata>
          </publicObject>
        XML
      end
      let(:cocina_body) do
        '{}'
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#containing_collections' do
    subject { instance.containing_collections }

    before do
      allow(resource_retriever).to receive(:cocina_body).and_return <<-COCINA
      {
        "structural": {
          "isMemberOf": [ "druid:jw357py5564" ]
        }
      }
      COCINA
    end

    it { is_expected.to eq ['jw357py5564'] }
  end

  describe '#catalog_key' do
    context 'with a FOLIO hrid' do
      let(:druid) { 'bb157hs6068' }

      it 'strips the leading a from the catkey value' do
        expect(instance.catalog_key).to eq '10624936'
      end
    end

    context 'without a FOLIO hrid' do
      let(:druid) { 'zb733jx3137' }

      it 'uses the catkey value' do
        expect(instance.catalog_key).to be_nil
      end
    end
  end

  describe '#doi and #doi_id' do
    context 'with a DOI' do
      let(:druid) { 'wm135gp2721' }

      it 'returns the DOI' do
        expect(instance.doi).to eq 'https://doi.org/10.25740/wm135gp2721'
        expect(instance.doi_id).to eq '10.25740/wm135gp2721'
      end
    end

    context 'without a DOI' do
      let(:druid) { 'rp193xx6845' }

      it 'returns nil' do
        expect(instance.doi).to be_nil
        expect(instance.doi_id).to be_nil
      end
    end
  end

  describe '#collection?' do
    before do
      allow(resource_retriever).to receive(:cocina_body).and_return(cocina.to_json)
    end

    context 'when a collection' do
      let(:cocina) { { 'type' => 'https://cocina.sul.stanford.edu/models/collection' } }

      it 'pulls the type from the cocina' do
        expect(instance.collection?).to be true
      end
    end

    context 'when an item' do
      let(:cocina) { { 'type' => 'https://cocina.sul.stanford.edu/models/book' } }

      it 'pulls the type from the cocina' do
        expect(instance.collection?).to be false
      end
    end
  end
end
