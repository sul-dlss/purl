# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AltmetricsComponent, type: :component do
  subject(:component) { described_class.new(purl_version:) }

  let(:version_id) { '1' }
  let(:purl_version) { PurlVersion.new(id: druid, version_id:, resource_retriever:) }
  let(:resource_retriever) { VersionedResourceRetriever.new(druid:, version_id:) }

  describe '#publication_date' do
    let(:druid) { 'wm135gp2721' }

    context 'with a publication date' do
      before do
        render_inline(component)
      end

      it 'returns the publication date' do
        expect(page).to have_css 'meta[name="citation_publication_date"][content="2023"]', visible: :all
      end
    end

    context 'with invalid data (from wf027xk3554)' do
      before do
        allow(resource_retriever).to receive(:cocina_body).and_return <<~JSON
          {
            "description": {
                              "adminMetadata": {
                                "event":[
                                  {
                                    "date": [
                                      {
                                        "encoding": {
                                          "code": "marc"
                                        }
                                      }
                                    ],
                                    "type":  "creation"
                                  }
                                ]
                              }
                            }
          }
        JSON
        allow(Honeybadger).to receive(:notify)

        render_inline(component)
      end

      it 'returns nil' do
        expect(Honeybadger).to have_received(:notify)
          .with('Invalid date value: ')
      end
    end

    context 'with invalid data (from db586ns4974)' do
      before do
        allow(resource_retriever).to receive(:cocina_body).and_return <<~JSON
          {
            "description": {
                              "adminMetadata": {
                                "event":[
                                  {
                                    "type":  "creation"
                                  }
                                ]
                              }
                            }
          }
        JSON
        allow(Honeybadger).to receive(:notify)

        render_inline(component)
      end

      it 'logs the error' do
        expect(Honeybadger).to have_received(:notify)
          .with('Malformed Cocina data: No date node found in creation event at description.adminMetadata.event.*.date for: wm135gp2721')
      end
    end
  end
end
