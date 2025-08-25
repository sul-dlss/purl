# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectComponent, type: :component do
  include ActionView::Helpers::UrlHelper

  let(:druid) { 'bb001dq8600' }

  let(:purl_version) do
    PurlVersion.new(id: druid, version_id: '1', head: true, state: 'available', updated_at: '2024-07-29T11:28:33-07:00',
                    resource_retriever: VersionedResourceRetriever.new(druid:, version_id: '1'))
  end

  before { render_inline(described_class.new(document: purl_version)) }

  describe 'subjects' do
    let(:component) { described_class.new(document: purl_version) }

    describe '#expand_subject_name' do
      subject { component.expand_subject_name(mods_subjects) }

      context 'with subjects that behave like names' do
        let(:mods_subjects) { [instance_double(ModsDisplay::Name::Person, name: 'Person Name')] }

        it { is_expected.to eq ['Person Name'] }
      end

      context 'with plain strings' do
        let(:mods_subjects) { %w[Subject2a Subject2b Subject2c] }

        it { is_expected.to eq %w[Subject2a Subject2b Subject2c] }
      end
    end
  end
end
