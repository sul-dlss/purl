require 'rails_helper'

RSpec.describe PurlResource do
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

  describe '#license' do
    let(:license) { subject.license }

    before do
      allow(subject).to receive(:public_xml_body).and_return <<-EOF
        <?xml version="1.0" encoding="UTF-8"?>
        <publicObject>
          <rightsMetadata>
            #{rights}
          </rightsMetadata>
        </publicObject>
      EOF
    end

    context 'with a license node' do
      let(:rights) do
        <<~EOF
          <use>
            <license>https://opensource.org/licenses/BSD-3-Clause</license>
          </use>
        EOF
      end

      it 'decodes the value' do
        expect(license.desc).to eq 'This work is licensed under a BSD-3-Clause "New" or "Revised" License'
      end
    end

    context 'with a uri attribute' do
      let(:rights) do
        <<~EOF
          <use>
            <machine type="creativeCommons" uri="https://creativecommons.org/licenses/by-nc/4.0/legalcode">junk</machine>
          </use>
        EOF
      end

      it 'decodes the value' do
        expect(license.desc).to eq 'This work is licensed under a CC-BY-NC-4.0 Attribution-NonCommercial International'
      end
    end

    context 'with a code' do
      let(:rights) do
        <<~EOF
          <use>
            <machine type="creativeCommons">by-nc</machine>
          </use>
        EOF
      end

      it 'decodes the value' do
        expect(license.desc).to eq 'This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License'
      end
    end
  end

  describe '#title' do
    it 'extracts the title from the MODS' do
      allow(subject).to receive(:mods_body).and_return <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <titleInfo>
          <title>The title from the MODS.</title>
        </titleInfo>
      </mods>
      EOF

      expect(subject.title).to eq 'The title from the MODS.'
    end

    it 'falls back on the public xml title' do
      allow(subject).to receive(:mods_body).and_return(nil)
      allow(subject).to receive(:public_xml_body).and_return <<-EOF

      <?xml version="1.0" encoding="UTF-8"?>
      <publicObject>
        <oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
          <dc:title>The title from the public XML</dc:title>
        </oai_dc:dc>
      </publicObject>
      EOF

      expect(subject.title).to eq 'The title from the public XML'
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

  describe '#collection' do
    it 'pulls the collection value from the RELS-EXT data' do
      allow(subject).to receive(:public_xml_body).and_return <<-EOF
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

      expect(subject.collection).to eq 'jw357py5564'
    end
  end
end
