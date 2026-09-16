# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifResourceSet do
  subject(:resource_set) do
    described_class.new(file_set, object_type:)
  end

  let(:object_type) { 'https://cocina.sul.stanford.edu/models/geo' }

  let(:file_set) do
    StructuralMetadata::FileSet.new(
      druid: 'zf181wv8446',
      json: {
        'externalIdentifier' => 'zf181wv8446_1',
        'structural' => {
          'contains' => files
        }
      }
    )
  end
  let(:files) do
    [
      {
        'externalIdentifier' => 'file-without-presentation-metadata',
        'filename' => 'image.jp2',
        'hasMimeType' => 'image/jp2',
        'access' => { 'view' => 'world' }
      },
      {
        'externalIdentifier' => 'thumbnail',
        'filename' => 'thumbnail.jp2',
        'hasMimeType' => 'image/jp2',
        'use' => 'thumbnail',
        'access' => { 'view' => 'world' },
        'presentation' => { 'height' => 512, 'width' => 512 }
      }
    ]
  end

  describe '#image_file' do
    let(:files) do
      [
        {
          'externalIdentifier' => 'image',
          'filename' => 'image.jp2',
          'hasMimeType' => 'image/jp2',
          'access' => { 'view' => 'world' },
          'presentation' => { 'height' => 640, 'width' => 480 }
        },
        {
          'externalIdentifier' => 'thumbnail',
          'filename' => 'thumbnail.jp2',
          'hasMimeType' => 'image/jp2',
          'use' => 'thumbnail',
          'access' => { 'view' => 'world' },
          'presentation' => { 'height' => 512, 'width' => 512 }
        }
      ]
    end

    it 'returns the first valid JP2 regardless of its role' do
      expect(resource_set.image_file.id).to eq 'image'
    end
  end

  describe '#primary' do
    it 'has no primary file for a geo object' do
      expect(resource_set.primary).to be_nil
    end
  end

  describe '#other_resources' do
    it 'returns all geo files without inspecting presentation metadata' do
      expect(resource_set.other_resources.map(&:id)).to eq %w[file-without-presentation-metadata thumbnail]
    end
  end
end
