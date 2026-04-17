# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Purl do
  subject(:instance) { described_class.new(id: druid) }

  describe '#releases' do
    subject { instance.releases }

    context 'with releases' do
      let(:druid) { 'bb000qr5025' }

      it { is_expected.to be_instance_of(Releases) }
    end

    context 'without releases' do
      let(:druid) { 'bw368gx2874' }

      it { is_expected.to be_instance_of(NullReleases) }
    end
  end
end
