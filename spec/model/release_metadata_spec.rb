require 'rails_helper'

RSpec.describe ReleaseMetadata do
  subject(:metadata) { described_class.new(meta_json) }
  let(:meta_json) { JSON.parse(fixture) }
  let(:fixture) { File.read('spec/fixtures/meta_json/sw_released.json') }

  describe '#released_to?' do
    context 'when the key is in the release tags' do
      it 'returns true' do
        expect(metadata.released_to?('Searchworks')).to be true
      end
    end

    context 'when the key is not in the release tags' do
      it 'returns false' do
        expect(metadata.released_to?('Earthworks')).to be false
      end
    end
  end
end
