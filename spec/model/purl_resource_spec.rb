require 'rails_helper'

RSpec.describe PurlResource do
  let(:instance) { described_class.new }

  describe 'resource methods' do
    let(:fake_response) { OpenStruct.new(success?: true, body: 'Content') }

    before do
      allow(subject).to receive(:fetch_resource).and_return(fake_response)
    end

    it 'fetches the response' do
      expect(subject.mods_resource).to eq fake_response
    end

    it 'returns the response body' do
      expect(subject.mods_body).to eq 'Content'
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
      expect { described_class.find('oo000oo0000') }.to raise_error PurlResource::ObjectNotReady
    end
  end

  describe '#title' do
    subject { instance.title }

    context 'with mods' do
      before do
        allow(instance).to receive(:mods_body).and_return mods_body
      end

      context 'with a single title' do
        let(:mods_body) do
          <<~EOF
            <?xml version="1.0" encoding="UTF-8"?>
            <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
              <titleInfo>
                <title>The title from the MODS.</title>
              </titleInfo>
            </mods>
          EOF
        end

        it { is_expected.to eq 'The title from the MODS.' }
      end

      context 'with a primary title' do
        let(:mods_body) do
          <<~EOF
            <?xml version="1.0" encoding="UTF-8"?>
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
          EOF
        end

        it { is_expected.to eq '[ North Korean poster collection]' }
      end
    end

    context 'without mods' do
      before do
        allow(instance).to receive(:mods_body).and_return(nil)
        allow(instance).to receive(:public_xml_body).and_return <<-EOF

        <?xml version="1.0" encoding="UTF-8"?>
        <publicObject>
          <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
            <dc:title>The title from the public XML</dc:title>
          </oai_dc:dc>
        </publicObject>
        EOF
      end

      it { is_expected.to eq 'The title from the public XML' }
    end
  end

  describe '#embeddable?' do
    subject { instance.embeddable? }
    let(:content_metadata) { instance_double(ContentMetadata, resources:) }

    before do
      allow(instance).to receive(:content_metadata).and_return(content_metadata)
    end

    context 'with resources' do
      let(:resources) { [instance_double(ContentMetadata::Resource)] }

      it { is_expected.to be true }
    end

    context 'without resources' do
      let(:resources) { [] }

      it { is_expected.to be false }
    end
  end

  describe '#description' do
    it 'extracts a description from the MODS abstract' do
      allow(subject).to receive(:mods_body).and_return <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <abstract>
          The abstract from the MODS.
        </abstract>
      </mods>
      EOF

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
    subject { described_class.new(id: 'oo000oo0000') }
    it 'includes the druid' do
      expect(subject.attributes).to include druid: 'oo000oo0000', druid_tree: 'oo/000/oo/0000'
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

    let(:t) { Time.zone.now - 1.day }

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
    context 'with a DOI' do
      before do
        allow(subject).to receive(:mods_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" version="3.7" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
            <identifier type="doi" displayLabel="DOI">https://doi.org/10.25740/bb051dp0564</identifier>
          </mods>
        EOF
      end

      it 'returns the DOI' do
        expect(subject.doi).to eq 'https://doi.org/10.25740/bb051dp0564'
        expect(subject.doi_id).to eq '10.25740/bb051dp0564'
      end
    end

    context 'without a DOI' do
      before do
        allow(subject).to receive(:mods_body).and_return <<-EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xlink="http://www.w3.org/1999/xlink" version="3.7" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
          </mods>
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

  describe 'analytics' do
    let(:visit) { Ahoy::Visit.create(started_at: Time.zone.now - 1.day) }

    before do
      5.times { Ahoy::Event.create(visit:, name: '$view', properties: { druid: 'bb051dp0564' }) }
      2.times { Ahoy::Event.create(visit:, name: 'download', properties: { druid: 'bb051dp0564' }) }
      allow(subject).to receive(:druid).and_return('bb051dp0564')
    end

    describe '#view_count' do
      it 'is the total number of view events for the druid' do
        expect(subject.view_count).to eq 5
      end
    end

    describe '#unique_view_count' do
      it 'is the number of visits with at least one view for the druid' do
        expect(subject.unique_view_count).to eq 1
      end
    end

    describe '#download_count' do
      it 'is the total number of download events for a purl' do
        expect(subject.download_count).to eq 2
      end
    end

    describe '#unique_download_count' do
      it 'is the number of visits with at least one download for the druid' do
        expect(subject.unique_download_count).to eq 1
      end
    end
  end
end
