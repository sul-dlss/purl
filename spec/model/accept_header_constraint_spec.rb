require 'rails_helper'

RSpec.describe AcceptHeaderConstraint do
  subject(:instance) { described_class.new }
  let(:v3_request) do
    double(
      'request',
      headers: { 'Accept' => 'application/ld+json;profile="http://iiif.io/api/presentation/3/context.json"' }
    )
  end
  let(:default_request) do
    double('request', headers: {})
  end
  describe '#matches?' do
    context 'with proper Accept headers' do
      it { expect(instance.matches?(v3_request)).to be_truthy }
    end
    context 'without proper Accept headers' do
      it { expect(instance.matches?(default_request)).to be_falsy }
    end
  end
end
