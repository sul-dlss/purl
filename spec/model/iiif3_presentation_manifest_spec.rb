# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Iiif3PresentationManifest do
  subject(:manifest) { described_class.new(resource, controller:) }

  let(:resource) { PurlVersion.new }
  let(:controller) { PurlController.new }

  describe '#body' do
    subject(:json) { manifest.body.to_ordered_hash }

    let(:resource) { PurlResource.find('bb157hs6068').version(:head) }
    let(:request) { ActionDispatch::TestRequest.create }

    before do
      allow(controller).to receive(:request).and_return(request)
    end

    it 'has correct data' do
      expect(json['@context']).to include 'http://www.w3.org/ns/anno.jsonld', 'http://iiif.io/api/presentation/3/context.json'
      expect(json['label'][:en].first).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
      expect(json['summary'][:en].first).to eq 'Tom.1. No.9. (top right).'
      expect(json['requiredStatement']['value'][:en].first).to start_with 'This work has been identified as being free of known restrictions'
      expect(json['seeAlso'].first['id']).to eq 'http://test.host/bb157hs6068.mods'
      expect(json['thumbnail']).to be_an Array
      expect(json['thumbnail'].size).to eq 1
      expect(json['thumbnail'].first['id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'
      expect(json['thumbnail'].first['type']).to eq 'Image'
      expect(json['thumbnail'].first['width']).to eq 400
      expect(json['thumbnail'].first['height']).to eq 345

      expect(json['items'].length).to eq 1
      canvas = json['items'].first

      expect(canvas['height']).to eq 9040
      expect(canvas['width']).to eq 10_481

      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      image = canvas['items'].first['items'].first
      expect(image['body']['height']).to eq 9040
      expect(image['body']['width']).to eq 10_481
      expect(image['body']['id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/full/0/default.jpg'
    end
  end
end
