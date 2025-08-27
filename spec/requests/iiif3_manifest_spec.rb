# frozen_string_literal: true

require 'rails_helper'
require 'iiif/v3/presentation' # Can we get the iiif-presentation gem to load this?

RSpec.describe 'IIIF v3 manifests' do
  let(:json) { response.parsed_body }

  context 'when a specific version is requested' do
    it 'is successful, has correct filepaths and metadata' do
      get '/zb733jx3137/version/2/iiif3/manifest'

      expect(json['@context']).to include 'http://www.w3.org/ns/anno.jsonld', 'http://iiif.io/api/presentation/3/context.json'
      expect(json['label']['en'].first).to eq 'Testing versioning issue with the review workflow in the new application'

      # canvas urls should point to the versioned file
      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      text = canvas['items'].first['items'].first
      expect(text['body']['id']).to eq 'https://stacks.stanford.edu/v2/file/zb733jx3137/version/2/test_file_v1.pdf'

      # probe_service should also point to the versioned file
      probe_service = text['body'].fetch('service').first
      expect(probe_service['type']).to eq 'AuthProbeService2'
      expect(probe_service['id']).to eq 'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Fv2%2Ffile%2Fzb733jx3137%2Fversion%2F2%2Ftest_file_v1.pdf'
      expect(probe_service['service']).to include hash_including 'type' => 'AuthAccessService2'
      expect(probe_service.dig('service', 0, 'service')).to include hash_including 'type' => 'AuthAccessTokenService2'
    end
  end

  context 'when purl does not exist (dark)' do
    it 'is not found' do
      get '/bc123df4567/iiif3/manifest'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when the object has no published files' do
    let(:druid) { 'bg387kw8222' }
    let(:resource) { instance_double(PurlResource, version:) }
    let(:version) { instance_double(PurlVersion, type: 'image', updated_at: 2.days.ago, cache_key: 'resource/xxx', ready?: true) }

    before do
      allow(PurlResource).to receive(:find).and_return(resource)
      allow(version).to receive(:iiif3_manifest).and_raise(IIIF::V3::Presentation::MissingRequiredKeyError)
    end

    it 'returns 404' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when requesting a /iiif/ route (not /iiif3)' do
    context 'with a collection' do
      it 'renders a iiif v3 collection manifest' do
        get '/sk882gx0113/iiif/manifest'

        expect(json['@context']).to include('http://iiif.io/api/presentation/3/context.json')
        expect(json['type']).to eq 'Collection'
      end
    end

    context 'with a file object' do
      it 'renders a iiif v3 manifest' do
        get '/gx074xz5520/iiif/manifest'

        expect(json['@context']).to include('http://iiif.io/api/presentation/3/context.json')
        expect(json['id']).to eq 'http://www.example.com/gx074xz5520/iiif/manifest'
        expect(json['label']['en']).to eq ['Minutes, 2006 May 18']
      end
    end
  end
end
