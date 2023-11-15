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

  context 'without a dataset genre' do
    let(:cocina_json) do
      <<~JSON
        {
          "externalIdentifier": "druid:hj293cv5980",
          "label": "Not a dataset",
          "description": {
                            "form": [{ "value": "media",
                                        "type":  "genre" }],
                            "identifier": []
                          }
        }
      JSON
    end

    it 'does not have type of Dataset' do
      expect(schema_dot_org).not_to include(
        "@type": 'Dataset'
      )
    end
  end

  context 'with multiple title values' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "title": [{"value": "My Dataset"},
                      {"value": "More title"}],
            "identifier": []
          }
        }
      JSON
    end

    it 'uses the first title' do
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

  context 'with description in abstract' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "note": [{"type": "abstract", "value": "About this dataset"}]
          }
        }
      JSON
    end

    it 'includes the description' do
      expect(schema_dot_org).to include(
        "description": 'About this dataset'
      )
    end
  end

  context 'with description in summary' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "note": [{"type": "summary", "value": "About this dataset"}]
          }
        }
      JSON
    end

    it 'includes the description' do
      expect(schema_dot_org).to include(
        "description": 'About this dataset'
      )
    end
  end

  context 'with no abstract or summary note' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "title": [{"value": "My Dataset"}]
          }
        }
      JSON
    end

    it 'uses the title instead' do
      expect(schema_dot_org).to include(
        "description": 'My Dataset'
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

  context 'when world downloadable' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }]
                          },
          "access": {"download": "world"}
        }
      JSON
    end

    it 'is accessibleForFree' do
      expect(schema_dot_org).to include(
        "isAccessibleForFree": true
      )
    end
  end

  context 'when not world downloadable' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }]
                          },
          "access": {"download": "stanford"}
        }
      JSON
    end

    it 'is not isAccessibleForFree' do
      expect(schema_dot_org).to include(
        "isAccessibleForFree": false
      )
    end
  end

  context 'with a license' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }]
                          },
          "access": {"license": "https://opendatacommons.org/licenses/by/1-0/"}
        }
      JSON
    end

    it 'includes the license' do
      expect(schema_dot_org).to include(
        "license": 'https://opendatacommons.org/licenses/by/1-0/'
      )
    end
  end

  context 'with a purl' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                            "purl": "https://purl.stanford.edu/hj293cv5980"
                          }
        }
      JSON
    end

    it 'includes a url' do
      expect(schema_dot_org).to include(
        "url": 'https://purl.stanford.edu/hj293cv5980'
      )
    end
  end

  context 'with contributors in a name' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "contributor": [{"name": {"value": "Doe, Jane"}},
                                           {"name": {"value": "Foo, John"}}]
                          }
        }
      JSON
    end

    it 'includes creator' do
      expect(schema_dot_org).to include(
        "creator": [{
          "@type": 'Person',
          "name": 'Doe, Jane'
        }, {
          "@type": 'Person',
          "name": 'Foo, John'
        }]
      )
    end
  end

  context 'with contributors in a structuredValue' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "contributor": [
                             {"name": [
                               { "structuredValue": [
                                    { "value": "Jane",
                                      "type": "forename" },
                                    { "value": "Doe",
                                      "type": "surname"}]
                                }
                             ]},
                             {"name": [
                               { "structuredValue": [
                                    { "value": "John",
                                      "type": "forename"},
                                    { "value": "Foo",
                                      "type": "surname"}]
                                }
                             ]}
                            ]
                          }
        }
      JSON
    end

    it 'includes creator' do
      expect(schema_dot_org).to include(
        "creator": [
          {
            "@type": 'Person',
            "name": 'Jane Doe',
            "givenName": 'Jane',
            "familyName": 'Doe'
          },
          {
            "@type": 'Person',
            "name": 'John Foo',
            "givenName": 'John',
            "familyName": 'Foo'
          }
        ]
      )
    end
  end

  context 'with an ORCID uri for the contributor' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "contributor": [{"name": {"value": "Doe, Jane"},
                                            "identifier": {"uri": "https://orcid.org/0000-0000-0000-0000"}}]
                          }
        }
      JSON
    end

    it 'includes the ORCID' do
      expect(schema_dot_org).to include(
        "creator": [{
          "@type": 'Person',
          "name": 'Doe, Jane',
          "sameAs": 'https://orcid.org/0000-0000-0000-0000'
        }]
      )
    end
  end

  context 'with an identifier of ORCID type for the contributor' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "contributor": [{"name": {"value": "Doe, Jane"},
                                            "identifier": {"value": "0000-0000-0000-0000",
                                                           "type": "ORCID"}
                                          }]
                          }
        }
      JSON
    end

    it 'includes the ORCID' do
      expect(schema_dot_org).to include(
        "creator": [{
          "@type": 'Person',
          "name": 'Doe, Jane',
          "sameAs": 'https://orcid.org/0000-0000-0000-0000'
        }]
      )
    end
  end

  context 'with a structuredValue name and ORCID' do
    let(:cocina_json) do
      <<~JSON
        { "description": { "form": [{ "value": "dataset",
                                      "type":  "genre" }],
                           "contributor": [
                             { "name": [
                               { "structuredValue": [
                                    { "value": "Jane",
                                      "type": "forename" },
                                    { "value": "Doe",
                                      "type": "surname"}
                                    ]
                                }
                              ],
                              "identifier": {"uri": "https://orcid.org/0000-0000-0000-0000"}
                            }]
                          }
        }
      JSON
    end

    it 'includes the ORCID' do
      expect(schema_dot_org).to include(
        "creator": [{
          "@type": 'Person',
          "name": 'Jane Doe',
          "givenName": 'Jane',
          "familyName": 'Doe',
          "sameAs": 'https://orcid.org/0000-0000-0000-0000'
        }]
      )
    end
  end
end
