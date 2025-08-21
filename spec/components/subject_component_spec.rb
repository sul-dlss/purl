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

    # rubocop:disable Style/OpenStructUse
    let(:subjects) do
      [OpenStruct.new(label: 'Subjects', values: [%w[Subject1a Subject1b], %w[Subject2a Subject2b Subject2c]])]
    end
    let(:name_subjects) do
      [OpenStruct.new(label: 'Subjects', values: [OpenStruct.new(name: 'Person Name', roles: %w[Role1 Role2])])]
    end
    let(:genres) { [OpenStruct.new(label: 'Genres', values: %w[Genre1 Genre2 Genre3])] }
    # rubocop:enable Style/OpenStructUse

    describe '#link_mods_subjects' do
      let(:linked_subjects) do
        component.link_mods_subjects(subjects.first.values.last)
      end

      it 'returns all subjects' do
        expect(linked_subjects).to eq %w[Subject2a Subject2b Subject2c]
      end
    end

    describe '#link_to_mods_subject' do
      it 'handles subjects that behave like names' do
        name_subject = component.link_to_mods_subject(name_subjects.first.values.first)
        expect(name_subject).to match('Person Name (Role1, Role2)')
      end
    end
  end
end
