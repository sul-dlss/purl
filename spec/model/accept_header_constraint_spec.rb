# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AcceptHeaderConstraint do
  subject { described_class.new }

  describe '#matches?' do
    context 'with proper Accept headers' do
      let(:v3_request) do
        instance_double(
          ActionDispatch::Request,
          headers: { 'Accept' => 'application/ld+json;profile="http://iiif.io/api/presentation/3/context.json"' }
        )
      end

      it { is_expected.to be_matches(v3_request) }
    end

    context 'without proper Accept headers' do
      let(:default_request) do
        instance_double(ActionDispatch::Request, headers: {})
      end

      it { is_expected.not_to be_matches(default_request) }
    end
  end
end
