require 'rails_helper'

RSpec.describe PurlResource do
  let(:instance) { described_class.new(id: druid) }
  let(:druid) { nil }

  describe '.find' do
    it 'validates the druid' do
      expect { described_class.find('xyz') }.to raise_error PurlResource::DruidNotValid
    end
  end

  describe '#persisted?' do
    it { is_expected.to be_persisted }
  end

  describe '#version' do
    it 'validates that the object is "ready"' do
      allow_any_instance_of(PurlVersion).to receive(:public_xml?).and_return(false)
      expect { instance.version(1) }.to raise_error PurlVersion::ObjectNotReady
    end
  end

  describe '#crawlable?' do
    subject { instance.crawlable? }
    let(:druid) { 'kn112rm5773' }

    context 'with a meta.json file in the object path' do
      before do
        allow(Rails.cache).to receive(:fetch).and_yield
        allow(DocumentCacheResource).to receive(:new).and_return(instance_double(DocumentCacheResource, body: "{\"true_targets\": #{true_targets} }",
                                                                                                        success?: true))
      end

      context 'when resource has a sitemap target' do
        let(:true_targets) { ['PURL sitemap'] }

        it { is_expected.to be true }
      end

      context 'when resource has a no sitemap' do
        let(:true_targets) { ['Searchworks'] }

        it { is_expected.to be false }
      end
    end
  end
end
