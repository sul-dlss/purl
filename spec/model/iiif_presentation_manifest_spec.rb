require 'rails_helper'

RSpec.describe IiifPresentationManifest do
  let(:resource) { PurlVersion.new }

  subject(:manifest) { described_class.new(resource) }

  describe '#stacks_iiif_base_url' do
    subject { manifest.stacks_iiif_base_url(druid, filename) }

    let(:druid) { 'druid' }
    let(:filename) { 'filename.jp2' }

    it { is_expected.to end_with '/image/iiif/druid%2Ffilename' }

    context 'with embedded dots' do
      let(:filename) { '2011-023LUDV-1971-b2_33.0_0008.jp2' }

      it { is_expected.to end_with '/druid%2F2011-023LUDV-1971-b2_33.0_0008' }
    end

    context 'with spaces' do
      let(:filename) { 'JungleCat x.jpg' }

      it { is_expected.to end_with '/druid%2FJungleCat%20x' }
    end

    context 'with percent signs' do
      let(:filename) { 'JungleCat%20x.jpg' }

      it { is_expected.to end_with '/druid%2FJungleCat%2520x' }
    end

    context 'with ampersand' do
      let(:filename) { 'JungleCat&x.jpg' }

      it { is_expected.to end_with '/druid%2FJungleCat%26x' }
    end
  end
end
