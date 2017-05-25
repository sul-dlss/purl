require 'rails_helper'

class TestPurlController
  delegate :iiif_manifest_url, :purl_url, to: :helpers
  delegate :original_url, to: :request

  def initialize
    Rails.application.routes.default_url_options = default_url_options
  end

  def request
    ActionDispatch::Request.new(
      'ORIGINAL_FULLPATH' => "/abc123/iiif/manifest.#{params[:format]}"
    )
  end

  def params
    {}
  end

  private

  def default_url_options
    { host: 'https://example.com' }
  end

  def helpers
    Rails.application.routes.url_helpers
  end
end

describe IiifPresentationManifest do
  let(:resource) { double }
  subject { described_class.new(resource) }

  describe '@id' do
    let(:controller) { TestPurlController.new }
    let(:resource) do
      double(
        PurlResource,
        druid: 'abc123',
        title: nil,
        type: nil,
        copyright: nil,
        description: nil,
        content_metadata: double(deliverable_files: []),
        public_xml_document: Nokogiri::XML('<xml/>')
      )
    end

    context 'when requested under json' do
      before { expect(controller).to receive_messages(params: { format: :json }) }

      it 'returns the current url (includes .json)' do
        manifest = subject.body(controller)
        expect(manifest['@id']).to match(%r{/abc123/iiif/manifest.json})
      end
    end

    context 'when requested not under json' do
      it 'returns the current url (does not include .json)' do
        manifest = subject.body(controller)
        expect(manifest['@id']).to match(%r{/abc123/iiif/manifest})
      end
    end
  end

  describe '#stacks_iiif_base_url' do
    it 'generates IIIF URLs for content metadata resources' do
      expect(subject.stacks_iiif_base_url('druid', 'filename')).to end_with '/image/iiif/druid%2Ffilename'
    end

    it 'strips file extensions' do
      expect(subject.stacks_iiif_base_url('druid', 'filename.jp2')).to end_with '/image/iiif/druid%2Ffilename'
    end

    it 'works with filenames with embedded dots' do
      expect(subject.stacks_iiif_base_url('abc', '2011-023LUDV-1971-b2_33.0_0008.jp2')).to end_with '/abc%2F2011-023LUDV-1971-b2_33.0_0008'
    end
  end
end
