require 'rails_helper'

RSpec.describe IiifPresentationManifest do
  let(:resource) { double }

  subject { described_class.new(resource) }

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
