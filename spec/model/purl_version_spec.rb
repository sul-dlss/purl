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
      let(:body) do
        <<-EOF
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
        EOF
      end
      let(:fake_response) { instance_double(Faraday::Response, success?: true, body:) }

      before do
        allow(resource_retriever).to receive(:fetch_resource).and_return(fake_response)
      end

      it 'checks if the request succeeded' do
        expect(instance).to be_mods
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

  describe '#title' do
    subject { instance.title }

    context 'with mods' do
      before do
        allow(instance).to receive(:public_xml_body).and_return public_xml_body
      end

      context 'with a single title' do
        let(:public_xml_body) do
          <<~MODS
            <?xml version="1.0" encoding="UTF-8"?>
            <publicObject>
              <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
                <titleInfo>
                  <title>The title from the MODS.</title>
                </titleInfo>
              </mods>
            </publicObject>
          MODS
        end

        it { is_expected.to eq 'The title from the MODS.' }
      end

      context 'with a primary title' do
        let(:public_xml_body) do
          <<~EOF
            <?xml version="1.0" encoding="UTF-8"?>
            <publicObject>
              <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
                <titleInfo type="alternative" altRepGroup="1">
                  <title>[Pukhan p'osŭt'ŏ k'ŏlleksyŏn]</title>
                </titleInfo>
                <titleInfo type="alternative" altRepGroup="1">
                  <title>[북한 포스터 컬렉션]</title>
                </titleInfo>
                <titleInfo usage="primary">
                  <nonSort>[ </nonSort>
                  <title>North Korean poster collection]</title>
                </titleInfo>
              </mods>
            </publicObject>
          EOF
        end

        it { is_expected.to eq '[ North Korean poster collection]' }
      end
    end

    context 'without mods' do
      before do
        allow(instance).to receive(:public_xml_body).and_return <<-EOF

        <?xml version="1.0" encoding="UTF-8"?>
        <publicObject>
          <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
            <dc:title>The title from the DC</dc:title>
          </oai_dc:dc>
        </publicObject>
        EOF
      end

      it { is_expected.to eq 'The title from the DC' }
    end
  end

  describe '#embeddable?' do
    subject { instance.embeddable? }

    let(:content_metadata) { instance_double(ContentMetadata, resources:) }

    before do
      allow(instance).to receive(:content_metadata).and_return(content_metadata)
    end

    context 'with resources' do
      let(:resources) { [instance_double(ResourceFile)] }

      it { is_expected.to be true }
    end

    context 'without resources' do
      let(:resources) { [] }

      it { is_expected.to be false }
    end
  end

  describe '#description' do
    let(:body) do
      <<-EOF
        <?xml version="1.0" encoding="UTF-8"?>
        <publicObject>
          <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <abstract>The abstract from the MODS.</abstract>
          </mods>
        </publicObject>
      EOF
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
    before do
      allow(instance).to receive(:iiif_manifest).and_return(iiif_manifest)
    end

    let(:iiif_manifest) do
      @iiif_manifest ||= double
    end

    it 'is the representative thumbnail for the object' do
      allow(iiif_manifest).to receive(:thumbnail_base_uri).and_return('http://some/iiif/path')

      expect(instance.representative_thumbnail).to eq 'http://some/iiif/path/full/!400,400/0/default.jpg'
    end

    it 'is blank if the object has no appropriate images' do
      allow(iiif_manifest).to receive(:thumbnail_base_uri).and_return(nil)

      expect(instance.representative_thumbnail).to be_blank
    end
  end

  describe '#containing_collections' do
    subject { instance.containing_collections }

    before do
      allow(instance).to receive(:public_xml_body).and_return <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <publicObject>
        <rdf:RDF xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about="info:fedora/druid:kn112rm5773">
        <fedora:isMemberOf rdf:resource="info:fedora/druid:jw357py5564"/>
        <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:jw357py5564"/>
        </rdf:Description>
        </rdf:RDF>
      </publicObject>
      EOF
    end

    it { is_expected.to eq ['jw357py5564'] }
  end

  describe '#catalog_key' do
    context 'with a native FOLIO hrid' do
      before do
        allow(resource_retriever).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <otherId name="folio_instance_hrid">in0001</otherId>
            </identityMetadata>
          </publicObject>
        EOF
      end

      it 'strips the leading a from the catkey value' do
        expect(instance.catalog_key).to eq 'in0001'
      end
    end

    context 'with a migrated FOLIO hrid' do
      before do
        allow(resource_retriever).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <otherId name="folio_instance_hrid">a12345</otherId>
            </identityMetadata>
          </publicObject>
        EOF
      end

      it 'strips the leading a from the catkey value' do
        expect(instance.catalog_key).to eq '12345'
      end
    end

    context 'with a catkey' do
      before do
        allow(resource_retriever).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <otherId name="catkey">12345</otherId>
            </identityMetadata>
          </publicObject>
        EOF
      end

      it 'uses the catkey value' do
        expect(instance.catalog_key).to eq '12345'
      end
    end

    context 'without any id data' do
      before do
        allow(resource_retriever).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
            </identityMetadata>
          </publicObject>
        EOF
      end

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

  describe '#object_type and #collection?' do
    context 'when a collection' do
      before do
        allow(instance).to receive(:public_xml_body).and_return(<<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <objectType>collection</objectType>
              <objectLabel>Acquisitions Serials</objectLabel>
            </identityMetadata>
          </publicObject>
        EOF
                                                               )
      end

      it 'pulls the value from the identity metadata' do
        expect(instance.object_type).to eq 'collection'
        expect(instance.collection?).to be true
      end
    end

    context 'when an item' do
      before do
        allow(instance).to receive(:public_xml_body).and_return(<<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <objectLabel>SUL Logo 2015</objectLabel>
              <objectType>item</objectType>
            </identityMetadata>
          </publicObject>
        EOF
                                                               )
      end

      it 'pulls the value from the identity metadata' do
        expect(instance.object_type).to eq 'item'
        expect(instance.collection?).to be false
      end
    end
  end

  describe '#schema_dot_org? and #schema_dot_org' do
    context 'with a dataset' do
      before do
        allow(resource_retriever).to receive(:cocina_body).and_return <<~JSON
          {
            "description": {
                              "form": [{ "value": "dataset",
                                        "type":  "genre" }],
                              "title": [{"value": "AVOIDDS: A dataset for vision-based aircraft detection"}],
                              "note": [{"type": "abstract", "value": "About this dataset."}]
                            },
            "identification": {"doi": "10.25740/hj293cv5980"}
          }
        JSON
      end

      it 'returns schema.org markup' do
        expect(instance.schema_dot_org).to include(
          '@context': 'http://schema.org',
          '@type': 'Dataset',
          name: 'AVOIDDS: A dataset for vision-based aircraft detection',
          isAccessibleForFree: false,
          creator: [],
          identifier: ['https://doi.org/10.25740/hj293cv5980'],
          description: 'About this dataset.'
        )
      end
    end

    context 'with a video' do
      before do
        allow(resource_retriever).to receive(:cocina_body).and_return <<~JSON
          {
            "externalIdentifier": "druid:tn153br1253",
            "description": {  "event": [{ "date": [{ "value": "2000", "type": "publication", "status": "primary"}] }],
                              "title": [{"value": "A Video Title"}],
                              "note": [{"type": "summary", "value": "What is in this video?"}]
                            },
            "access": {"download": "world"},
            "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                                        "structural": {
                                                        "contains": [{"filename": "tn153br1253_thumb.jp2",
                                                                      "hasMimeType": "image/jp2"},
                                                                    {"filename": "tn153br1253_video_sl.mp4",
                                                                     "access": { "view": "world",
                                                                                 "download": "world",
                                                                                 "controlledDigitalLending": false },
                                                                     "hasMimeType": "video/mp4"}]
                                                      }
                                        }]
                          }
          }
        JSON
      end

      it 'returns schema.org markup' do
        expect(instance.schema_dot_org).to include(
          '@context': 'http://schema.org',
          '@type': 'VideoObject',
          name: 'A Video Title',
          description: 'What is in this video?',
          uploadDate: '2000',
          thumbnailUrl: 'https://stacks.stanford.edu/file/druid:tn153br1253/tn153br1253_thumb.jp2',
          embedUrl: 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Ftn153br1253'
        )
      end
    end

    context 'with a format not relevant for schema.org' do
      before do
        allow(resource_retriever).to receive(:cocina_body).and_return <<~JSON
          {
            "description": {
                              "form": [{ "value": "image",
                                        "type":  "genre" }],
                              "title": [{"value": "Not a dataset"}],
                              "note": [{"type": "abstract", "value": "About this item."}]
                            }
          }
        JSON
      end

      it 'returns false' do
        expect(instance.schema_dot_org?).to be false
      end
    end
  end
end
