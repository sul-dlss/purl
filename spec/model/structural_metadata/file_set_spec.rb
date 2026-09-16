# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StructuralMetadata::FileSet do
  subject(:file_set) { described_class.new(druid: 'zf181wv8446', json:) }

  let(:json) do
    {
      'externalIdentifier' => 'zf181wv8446_1',
      'structural' => {
        'contains' => files
      }
    }
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
      expect(file_set.image_file.id).to eq 'image'
    end
  end

  describe '#thumbnail_file' do
    it 'prefers a thumbnail over an earlier JP2 without presentation metadata' do
      expect(file_set.thumbnail_file.id).to eq 'thumbnail'
    end

    context 'when no thumbnail is present' do
      let(:files) do
        [
          {
            'externalIdentifier' => 'image',
            'filename' => 'image.jp2',
            'hasMimeType' => 'image/jp2',
            'access' => { 'view' => 'world' },
            'presentation' => { 'height' => 640, 'width' => 480 }
          }
        ]
      end

      it 'falls back to another JP2' do
        expect(file_set.thumbnail_file.id).to eq 'image'
      end
    end

    context 'when the thumbnail is missing presentation metadata' do
      let(:files) do
        [
          {
            'externalIdentifier' => 'thumbnail',
            'filename' => 'thumbnail.jp2',
            'hasMimeType' => 'image/jp2',
            'use' => 'thumbnail',
            'access' => { 'view' => 'world' }
          }
        ]
      end

      it 'raises an error' do
        expect { file_set.thumbnail_file }
          .to raise_error(StructuralMetadata::File::MissingPresentationMetadata,
                          'Thumbnail file thumbnail.jp2 is missing required presentation height or width')
      end
    end

    context 'when the fallback JP2 is missing presentation metadata' do
      let(:files) do
        [
          {
            'externalIdentifier' => 'image',
            'filename' => 'image.jp2',
            'hasMimeType' => 'image/jp2',
            'access' => { 'view' => 'world' }
          }
        ]
      end

      it 'raises an error' do
        expect { file_set.thumbnail_file }
          .to raise_error(StructuralMetadata::File::MissingPresentationMetadata,
                          'Thumbnail file image.jp2 is missing required presentation height or width')
      end
    end
  end
end
