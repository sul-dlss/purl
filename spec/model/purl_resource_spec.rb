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
end
