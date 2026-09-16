# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StructuralMetadata::File do
  subject(:file) { described_class.new(druid: 'bc123df4567', json:, fileset:) }

  let(:json) { { 'hasMimeType' => mimetype } }
  let(:fileset) { instance_double(StructuralMetadata::FileSet, label: 'File set') }

  describe '#jp2?' do
    context 'when the file is a JP2' do
      let(:mimetype) { 'image/jp2' }

      it { is_expected.to be_jp2 }
    end

    context 'when the file is not a JP2' do
      let(:mimetype) { 'image/jpeg' }

      it { is_expected.not_to be_jp2 }
    end
  end
end
