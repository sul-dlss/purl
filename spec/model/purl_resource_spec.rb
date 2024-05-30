require 'rails_helper'

RSpec.describe PurlResource do
  let(:instance) { described_class.new(id: druid) }
  let(:druid) { nil }

  describe 'resource methods' do
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
    let(:fake_response) { OpenStruct.new(success?: true, body:) }

    before do
      allow(subject).to receive(:fetch_resource).and_return(fake_response)
    end

    it 'checks if the request succeeded' do
      expect(subject).to be_mods
    end
  end

  describe '.find' do
    it 'validates the druid' do
      expect { described_class.find('xyz') }.to raise_error PurlResource::DruidNotValid
    end

    it 'validates that the object is "ready"' do
      allow_any_instance_of(described_class).to receive(:public_xml?).and_return(false)
      expect { described_class.find('bc421tk1152') }.to raise_error PurlResource::ObjectNotReady
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

    before { allow(subject).to receive(:public_xml_body).and_return(body) }

    it 'extracts a description from the MODS abstract' do
      expect(subject.description).to eq 'The abstract from the MODS.'
    end
  end

  describe '#ready?' do
    it 'is ready if the public xml is present' do
      allow(subject).to receive(:public_xml_body).and_return('ok')

      expect(subject).to be_ready
    end
  end

  describe '#attributes' do
    subject { described_class.new(id: 'bc421tk1152') }
    it 'includes the druid' do
      expect(subject.attributes).to include druid: 'bc421tk1152', druid_tree: 'bc/421/tk/1152'
    end
  end

  describe '#persisted?' do
    it { is_expected.to be_persisted }
  end

  describe '#cache_key' do
    subject { described_class.new(id: 'oo000oo0000') }

    it 'namespaces the purl resource' do
      expect(subject.cache_key).to eq 'purl_resource/druid:oo000oo0000'
    end
  end

  describe '#updated_at' do
    before do
      allow(subject).to receive(:public_xml_resource).and_return(public_xml_resource)
    end

    let(:public_xml_resource) do
      @public_xml_resource ||= double
    end

    let(:t) { 1.day.ago }

    it 'pulls the updated time from the resource' do
      allow(public_xml_resource).to receive(:updated_at).and_return(t)
      expect(subject.updated_at).to eq t
    end

    it 'pulls the updated time from the HTTP request' do
      allow(public_xml_resource).to receive(:header).and_return(last_modified: t)
      expect(subject.updated_at).to eq t
    end
  end

  describe '#representative_thumbnail' do
    before do
      allow(subject).to receive(:iiif_manifest).and_return(iiif_manifest)
    end

    let(:iiif_manifest) do
      @iiif_manifest ||= double
    end

    it 'is the representative thumbnail for the object' do
      allow(iiif_manifest).to receive(:thumbnail_base_uri).and_return('http://some/iiif/path')

      expect(subject.representative_thumbnail).to eq 'http://some/iiif/path/full/!400,400/0/default.jpg'
    end

    it 'is blank if the object has no appropriate images' do
      allow(iiif_manifest).to receive(:thumbnail_base_uri).and_return(nil)

      expect(subject.representative_thumbnail).to be_blank
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

  describe '#crawlable?' do
    subject { instance.crawlable? }
    let(:druid) { 'druid:kn112rm5773' }

    context 'with a meta.json file in the object path' do
      before do
        allow(DocumentCacheResource).to receive(:new).and_return(instance_double(DocumentCacheResource, body: "{\"true_targets\": #{true_targets} }",
                                                                                                        success?: true))
      end

      context 'when resource has a sitemap target' do
        let(:true_targets) { ['PURL sitemap'] }

        it { is_expected.to be true }
      end

      context 'when resource has a no sitemap' do
        let(:true_targets) { ['Searchworks'] }

        it { is_expected.to be false }
      end
    end
  end

  describe '#catalog_key' do
    context 'with a native FOLIO hrid' do
      before do
        allow(subject).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <otherId name="folio_instance_hrid">in0001</otherId>
            </identityMetadata>
          </publicObject>
        EOF
      end

      it 'strips the leading a from the catkey value' do
        expect(subject.catalog_key).to eq 'in0001'
      end
    end

    context 'with a migrated FOLIO hrid' do
      before do
        allow(subject).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <otherId name="folio_instance_hrid">a12345</otherId>
            </identityMetadata>
          </publicObject>
        EOF
      end

      it 'strips the leading a from the catkey value' do
        expect(subject.catalog_key).to eq '12345'
      end
    end

    context 'with a catkey' do
      before do
        allow(subject).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
              <otherId name="catkey">12345</otherId>
            </identityMetadata>
          </publicObject>
        EOF
      end

      it 'uses the catkey value' do
        expect(subject.catalog_key).to eq '12345'
      end
    end

    context 'without any id data' do
      before do
        allow(subject).to receive(:public_xml_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <identityMetadata>
            </identityMetadata>
          </publicObject>
        EOF
      end

      it 'uses the catkey value' do
        expect(subject.catalog_key).to be_nil
      end
    end
  end

  describe '#doi and #doi_id' do
    before { allow(subject).to receive(:public_xml_body).and_return(body) }

    context 'with a DOI' do
      let(:body) do
        <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
              <identifier type="doi" displayLabel="DOI">https://doi.org/10.25740/bb051dp0564</identifier>
            </mods>
          </publicObject>
        EOF
      end

      it 'returns the DOI' do
        expect(subject.doi).to eq 'https://doi.org/10.25740/bb051dp0564'
        expect(subject.doi_id).to eq '10.25740/bb051dp0564'
      end
    end

    context 'without a DOI' do
      let(:body) do
        <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <publicObject>
            <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            </mods>
          </publicObject>
        EOF
      end

      it 'returns nil' do
        expect(subject.doi).to be_nil
        expect(subject.doi_id).to be_nil
      end
    end
  end

  describe '#object_type and #collection?' do
    context 'when a collection' do
      before do
        allow(subject).to receive(:public_xml_body).and_return(<<-EOF
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
        expect(subject.object_type).to eq 'collection'
        expect(subject.collection?).to be true
      end
    end

    context 'when an item' do
      before do
        allow(subject).to receive(:public_xml_body).and_return(<<-EOF
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
        expect(subject.object_type).to eq 'item'
        expect(subject.collection?).to be false
      end
    end
  end

  describe '#schema_dot_org? and #schema_dot_org' do
    context 'with a dataset' do
      before do
        allow(subject).to receive(:cocina_body).and_return <<~JSON
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
        expect(subject.schema_dot_org).to include(
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
        allow(subject).to receive(:cocina_body).and_return <<~JSON
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
        expect(subject.schema_dot_org).to include(
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
        allow(subject).to receive(:cocina_body).and_return <<~JSON
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
        expect(subject.schema_dot_org?).to be false
      end
    end
  end
end
