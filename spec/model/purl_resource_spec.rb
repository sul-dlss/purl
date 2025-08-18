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
    let(:druid) { 'kn112rm5773' }

    context 'when head version requested' do
      before do
        allow(instance).to receive(:version_manifest).and_return(
          { 'versions' => { '1' => { 'state' => 'available' }, '2' => { 'state' => 'available' }, '3' => { 'state' => 'available
            ' } }, 'head' => 3 }
        )
      end

      let(:head_version) { instance.version(:head) }

      it 'returns the head version' do
        expect(head_version).to be_a(PurlVersion)
        expect(head_version.version_id).to eq(3)
        expect(head_version).to be_head
      end
    end
  end

  describe '#versions' do
    let(:druid) { 'zb733jx3137' }

    it 'sets the head property on versions' do
      expect(instance.versions.map(&:head)).to eq([false, false, false, true])
    end

    it 'sets the updated_at property on versions' do
      expect(instance.versions.filter(&:ready?).map(&:updated_at)).to all(be_a(DateTime))
    end

    it 'sets the state property on versions' do
      expect(instance.versions.map(&:state)).to eq(%w[available available available available])
    end
  end

  describe '#crawlable?' do
    subject { instance.crawlable? }

    let(:druid) { 'kn112rm5773' }

    context 'with a meta.json file in the object path' do
      before do
        allow(Rails.cache).to receive(:fetch).and_yield
        allow(DocumentCacheResource).to receive(:new).and_return(instance_double(DocumentCacheResource, body:,
                                                                                                        success?: true))
      end

      context 'when resource has a sitemap target' do
        let(:body) { '{"sitemap":true}' }

        it { is_expected.to be true }
      end

      context 'when resource has a no sitemap' do
        let(:body) { '{"sitemap":false}' }

        it { is_expected.to be false }
      end
    end
  end
end
