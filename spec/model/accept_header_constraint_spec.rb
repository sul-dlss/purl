require 'rails_helper'

RSpec.describe AcceptHeaderConstraint do
  subject(:instance) { described_class.new }

  describe '#matches?' do
    context 'with Accept header that has v3 profile' do
      let(:request) do
        double(
          'request',
          headers: { 'Accept' => 'application/ld+json;profile="http://iiif.io/api/presentation/3/context.json"' }
        )
      end
      it { expect(instance.matches?(request)).to be_truthy }
    end

    context 'with Accept header that has v3 profile and weight' do
      let(:request) do
        double(
          'request',
          headers: { 'Accept' => 'application/ld+json;q=0.5;profile="http://iiif.io/api/presentation/3/context.json"' }
        )
      end
      it { expect(instance.matches?(request)).to be_truthy }
    end

    context 'with Accept header that has v3 and v2 profile and weight' do
      let(:request) do
        double(
          'request',
          headers: { 'Accept' => 'application/ld+json;q=0.5;profile="http://iiif.io/api/presentation/2/context.json", application/ld+json;profile="http://iiif.io/api/presentation/3/context.json"' }
        )
      end
      it { expect(instance.matches?(request)).to be_truthy }
    end

    context 'without proper Accept headers' do
      let(:default_request) do
        double('request', headers: {})
      end
      it { expect(instance.matches?(default_request)).to be_falsy }
    end
  end
end
