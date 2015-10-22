require 'rails_helper'

describe PurlResource do
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
    it 'extracts the title from the MODS' do
      # rubocop:disable Metrics/LineLength
      allow(subject).to receive(:mods_body).and_return <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <titleInfo>
          <title>The title from the MODS.</title>
        </titleInfo>
      </mods>
      EOF
      # rubocop:enable Metrics/LineLength

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
      # rubocop:disable Metrics/LineLength
      allow(subject).to receive(:mods_body).and_return <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <abstract>
          The abstract from the MODS.
        </abstract>
      </mods>
      EOF
      # rubocop:enable Metrics/LineLength

      expect(subject.description).to eq 'The abstract from the MODS.'
    end
  end

  describe '#ready?' do
    it 'is ready if the public xml is present' do
      allow(subject).to receive(:public_xml_body).and_return('ok')

      expect(subject).to be_ready
    end
  end

  describe '#flipbook?' do
    it 'is a flipbook if it is a book' do
      allow(subject).to receive(:type).and_return('Book')

      expect(subject).to be_flipbook
    end

    it 'is a flipbook if it is a manuscript' do
      allow(subject).to receive(:type).and_return('Manuscript')

      expect(subject).to be_flipbook
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
end
