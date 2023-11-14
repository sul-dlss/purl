require 'rails_helper'

RSpec.describe Metadata::SchemaDotOrg do
  let(:schema_dot_org) { described_class.call(cocina_json) }

  context 'with dataset genre' do
    let(:cocina_json) do
      <<~JSON
        {
          "externalIdentifier": "druid:hj293cv5980",
          "label": "AVOIDDS: A dataset for vision-based aircraft detection",
          "description": {
                            "form": [{ "value": "dataset",
                                       "type":  "genre" }],
                            "identifier": []
                         }
        }
      JSON
    end

    it 'has type of Dataset' do
      expect(schema_dot_org).to include(
        "@context": 'http://schema.org',
        "@type": 'Dataset'
      )
    end
  end

  context 'with a single title value' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "title": [{"value": "My Dataset"}],
            "identifier": []
          }
        }
      JSON
    end

    it 'includes the title' do
      expect(schema_dot_org).to include(
        "name": 'My Dataset'
      )
    end
  end

  context 'with a structuredValue title' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "title": [
              {"structuredValue": [
                 {"value": "My Dataset",
                  "type": "main title"},
                 {"value": "More title",
                  "type": "subtitle"}
                ],
               "status": "primary"}
            ],
            "identifier": []
          }
        }
      JSON
    end

    it 'includes the title' do
      expect(schema_dot_org).to include(
        "name": 'My Dataset\nMore title'
      )
    end
  end

  context 'with DOI in identification' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "title": [{"value": "My Dataset"}]
          },
          "identification": {"doi": "10.25740/hj293cv5980"}
        }
      JSON
    end

    it 'includes the DOI' do
      expect(schema_dot_org).to include(
        "identifier": ['https://doi.org/10.25740/hj293cv5980']
      )
    end
  end

  context 'with DOI in identifier uri' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "identifier": [
                             { "uri": "https://doi.org/10.25740/hj293cv5980" }
                           ]
                          }
        }
      JSON
    end

    it 'includes the DOI' do
      expect(schema_dot_org).to include(
        "identifier": ['https://doi.org/10.25740/hj293cv5980']
      )
    end
  end

  context 'with DOI in identifier value' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "identifier": [
                              { "value": "https://doi.org/10.25740/hj293cv5980",
                                "type": "doi" }
                            ]
                          }
        }
      JSON
    end

    it 'includes the DOI' do
      expect(schema_dot_org).to include(
        "identifier": ['https://doi.org/10.25740/hj293cv5980']
      )
    end
  end

  context 'with no identifiers' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "identifier": []
                          }
        }
      JSON
    end

    it 'includes no identifier' do
      expect(schema_dot_org).not_to have_key('identifier')
    end
  end
end
