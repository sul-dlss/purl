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

    it 'has a type of Dataset' do
      expect(schema_dot_org).to include(
        "@context": 'http://schema.org',
        "@type": 'Dataset'
      )
    end
  end

  context 'without a dataset or media form' do
    let(:cocina_json) do
      <<~JSON
        {
          "externalIdentifier": "druid:hj293cv5980",
          "label": "Not a dataset",
          "description": {
                            "form": [{ "value": "audio",
                                        "type":  "genre" }],
                            "identifier": []
                          },
          "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/audio"}]}
        }
      JSON
    end

    it 'does not have type' do
      expect(schema_dot_org).not_to have_key('@type')
    end
  end

  context 'with a video resources type' do
    let(:cocina_json) do
      <<~JSON
        {
          "externalIdentifier": "druid:hj293cv5980",
          "label": "A video about robots",
          "description": {},
          "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                                       "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                                      "access": { "view": "world",
                                                                                  "download": "world",
                                                                                  "controlledDigitalLending": false },
                                                                      "hasMimeType": "video/mp4" }] }
                                      }]
                         },
          "access": {"download": "world"}
        }
      JSON
    end

    it 'has type of VideoObject' do
      expect(schema_dot_org).to include(
        "@context": 'http://schema.org',
        "@type": 'VideoObject'
      )
    end
  end

  context 'without a world-downloadable video' do
    let(:cocina_json) do
      <<~JSON
        {
          "externalIdentifier": "druid:hj293cv5980",
          "label": "A video about robots",
          "description": {},
          "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                                       "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                                      "access": { "view": "world",
                                                                                  "download": "stanford",
                                                                                  "controlledDigitalLending": false },
                                                                      "hasMimeType": "video/mp4" }] }
                                      }]
                         },
          "access": {"download": "world"}
        }
      JSON
    end

    it 'does not have type of VideoObject' do
      expect(schema_dot_org).not_to include(
        "@type": 'VideoObject'
      )
    end
  end

  context 'without a video file' do
    let(:cocina_json) do
      <<~JSON
        {
          "externalIdentifier": "druid:hj293cv5980",
          "label": "A video about robots",
          "description": {},
          "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                                       "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                                      "access": { "view": "world",
                                                                                  "download": "world",
                                                                                  "controlledDigitalLending": false },
                                                                      "hasMimeType": "audio/mp4" }] }
                                      }]
                         },
          "access": {"download": "world"}
        }
      JSON
    end

    it 'does not have type of VideoObject' do
      expect(schema_dot_org).not_to include(
        "@type": 'VideoObject'
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
            "form": [{ "value": "dataset",
                       "type":  "genre" }],
            "identifier": []
          }
        }
      JSON
    end

    it 'includes the title' do
      expect(schema_dot_org).to include(
        "name": 'My Dataset: More title'
      )
    end
  end

  context 'with description in abstract' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "note": [{"type": "abstract", "value": "About this item"}],
            "form": [{ "value": "dataset",
                       "type":  "genre" }]
          }
        }
      JSON
    end

    it 'includes the description' do
      expect(schema_dot_org).to include(
        "description": 'About this item'
      )
    end
  end

  context 'with description in summary' do
    let(:cocina_json) do
      <<~JSON
        {
          "description": {
            "note": [{"type": "summary", "value": "About this dataset"}],
            "form": [{"value": "dataset",
                      "type":  "genre" }]
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
            "title": [{"value": "My Dataset"}],
            "form": [{"value": "dataset",
                      "type":  "genre" }]
          }
        }
      JSON
    end

    it 'does not include a description ' do
      expect(schema_dot_org).not_to have_key('description')
    end
  end

  context 'with a Dataset' do
    context 'with DOI in identification' do
      let(:cocina_json) do
        <<~JSON
          {
            "description": {
              "title": [{"value": "My Dataset"}],
              "form": [{"value": "dataset",
                        "type":  "genre" }]
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

    context 'with non-DOI in identifier uri' do
      let(:cocina_json) do
        <<~JSON
          {
            "description": { "form": [{ "value": "dataset",
                                        "type":  "genre" }],
                            "identifier": [
                              { "uri": "https://identifier.example.com/123" }
                            ]
                            }
          }
        JSON
      end

      it 'does not includes the identifier' do
        expect(schema_dot_org).not_to have_key('identifier')
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

    context 'when dataset is world downloadable' do
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
          "creator": [{ "@type": 'Person',
                        "name": 'Doe, Jane' },
                      { "@type": 'Person',
                        "name": 'Foo, John' }]
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

    context 'with an ORCID identifier uri for the contributor' do
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
          'creator': [{
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

  context 'with a Video' do
    let(:cocina_json) do
      <<~JSON
        {
          "externalIdentifier": "druid:tn153br1253",
          "description": { "event": [{ "date": [{ "value": "2000", "type": "publication" },
                                                 { "value": "2014", "status": "primary", "type": "publication" }]
                                      }]
                          },
          "access": {"download": "world"},
          "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                                      "structural": {
                                                      "contains": [{"filename": "tn153br1253_thumb.jp2",
                                                                    "hasMimeType": "image/jp2"},
                                                                   {"filename": "tn153br1253_video_sl.mp4",
                                                                    "access": { "view": "world",
                                                                                  "download": "world",
                                                                                  "controlledDigitalLending": false },
                                                                    "hasMimeType": "video/mp4"}]
                                                    }
                                      }]
                        }
        }
      JSON
    end

    context 'with a thumbnail' do
      it 'includes the thumbnail' do
        expect(schema_dot_org).to include(
          "thumbnailUrl": 'https://stacks.stanford.edu/file/druid:tn153br1253/tn153br1253_thumb.jp2'
        )
      end
    end

    context 'with no thumbnail' do
      let(:cocina_json) do
        <<~JSON
          {
            "externalIdentifier": "druid:tn153br1253",
            "description": { },
            "access": {"download": "world"},
            "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                                         "structural": {"contains": [{"filename": "tn153br1253_history_sl.mp4",
                                                                      "access": { "view": "world",
                                                                                  "download": "world",
                                                                                  "controlledDigitalLending": false },
                                                                      "hasMimeType": "video/mp4"}]
                                                        }
                                        }]
                          }
          }
        JSON
      end

      it 'does not include a thumbnail' do
        expect(schema_dot_org).not_to have_key('thumbnailUrl')
      end
    end

    context 'with an embeddable video' do
      it 'includes the embed_url' do
        expect(schema_dot_org).to include(
          'embedUrl': 'https://embed.stanford.edu/iframe/?url=https%3A%2F%2Fpurl.stanford.edu%2Ftn153br1253'
        )
      end
    end

    context 'with an event date' do
      context 'with value and status of primary' do
        it 'includes the uploadDate' do
          expect(schema_dot_org).to include(
            'uploadDate': '2014'
          )
        end
      end

      context 'with a structuredValue with status of primary' do
        let(:cocina_json) do
          <<~JSON
            {
              "externalIdentifier": "druid:tn153br1253",
              "description": { "event": [{ "type": "publication",
                                            "date": [{ "structuredValue": [{"value": "2000"}],
                                                       "type": "publication" },
                                                       { "structuredValue": [{"value": "2014"}],
                                                       "status": "primary",
                                                       "type": "publication" }]
                                          }]
                              },
              "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                             "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                             "access": { "view": "world",
                                                                         "download": "world",
                                                                         "controlledDigitalLending": false },
                                                             "hasMimeType": "video/mp4" }] }
                             }]
                },
              "access": {"download": "world"}
            }
          JSON
        end

        it 'includes the primary uploadDate' do
          expect(schema_dot_org).to include(
            'uploadDate': '2014'
          )
        end
      end

      context 'with no date having a status of primary' do
        let(:cocina_json) do
          <<~JSON
            {
              "externalIdentifier": "druid:tn153br1253",
              "description": { "event": [{ "type": "publication",
                                            "date": [{ "value": "2014",
                                                       "type": "publication" },
                                                      { "value": "2000",
                                                       "type": "publication" }]
                                          }]
                              },
              "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                              "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                              "access": { "view": "world",
                                                                          "download": "world",
                                                                          "controlledDigitalLending": false },
                                                              "hasMimeType": "video/mp4" }] }
                              }]
                 },
              "access": {"download": "world"}
            }
          JSON
        end

        it 'selects the first one for the uploadDate' do
          expect(schema_dot_org).to include(
            'uploadDate': '2014'
          )
        end
      end

      context 'with no structuredValue date having a status of primary' do
        let(:cocina_json) do
          <<~JSON
            {
              "externalIdentifier": "druid:tn153br1253",
              "description": { "event": [{ "type": "publication",
                                            "date": [{ "structuredValue": [{"value": "2014"}],
                                                       "type": "publication" },
                                                     { "structuredValue": [{"value": "2000"}],
                                                       "type": "publication" }]
                                          }]
                              },
              "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                             "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                             "access": { "view": "world",
                                                                         "download": "world",
                                                                         "controlledDigitalLending": false },
                                                             "hasMimeType": "video/mp4" }] }
                             }]
                },
              "access": {"download": "world"}
            }
          JSON
        end

        it 'selects the first one for the uploadDate' do
          expect(schema_dot_org).to include(
            'uploadDate': '2014'
          )
        end
      end

      context 'with type publication and structuredValue having no type' do
        let(:cocina_json) do
          <<~JSON
            {
              "externalIdentifier": "druid:tn153br1253",
              "description": { "event": [{ "type": "publication",
                                            "date": [{ "structuredValue": [{"value": "2014"}]},
                                                     { "structuredValue": [{"value": "2000"}]}
                                                    ]
                                          }]
                              },
              "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                             "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                             "access": { "view": "world",
                                                                         "download": "world",
                                                                         "controlledDigitalLending": false },
                                                             "hasMimeType": "video/mp4" }] }
                             }]
                },
              "access": {"download": "world"}
            }
          JSON
        end

        it 'selects the first one for the uploadDate' do
          expect(schema_dot_org).to include(
            'uploadDate': '2014'
          )
        end
      end

      context 'with type publication and date having no type' do
        let(:cocina_json) do
          <<~JSON
            {
              "externalIdentifier": "druid:tn153br1253",
              "description": { "event": [{ "type": "publication",
                                           "date": [{ "value": "2000", "type": "secondary" },
                                                    { "value": "2014" }]
                                         }]
                              },
              "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                             "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                              "access": { "view": "world",
                                                                          "download": "world",
                                                                          "controlledDigitalLending": false },
                                                              "hasMimeType": "video/mp4" }] }
                            }]
                 },
              "access": {"download": "world"}
            }
          JSON
        end

        it 'selects the first one for the uploadDate' do
          expect(schema_dot_org).to include(
            'uploadDate': '2014'
          )
        end
      end

      context 'with event type having no type' do
        let(:cocina_json) do
          <<~JSON
            {
              "externalIdentifier": "druid:tn153br1253",
              "description": { "event": [{ "date": [{ "value": "2000", "type": "secondary" },
                                                    { "value": "2014" }]
                                         }]
                              },
              "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                              "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                              "access": { "view": "world",
                                                                          "download": "world",
                                                                          "controlledDigitalLending": false },
                                                              "hasMimeType": "video/mp4" }] }
                              }]
                 },
              "access": {"download": "world"}
            }
          JSON
        end

        it 'selects the first date for the uploadDate' do
          expect(schema_dot_org).to include(
            'uploadDate': '2014'
          )
        end
      end

      context 'with no relevant event dates' do
        let(:cocina_json) do
          <<~JSON
            {
              "externalIdentifier": "druid:tn153br1253",
              "description": {"event": [{ "date": [{ "value": "2000", "type": "secondary" },
                                                     { "value": "2014", "type": "creation" }]
                                          }]
                              },
              "structural": {"contains": [{"type": "https://cocina.sul.stanford.edu/models/resources/video",
                              "structural": { "contains": [{ "type": "https://cocina.sul.stanford.edu/models/file",
                                                              "access": { "view": "world",
                                                                          "download": "world",
                                                                          "controlledDigitalLending": false },
                                                              "hasMimeType": "video/mp4" }] }
                              }]
                 },
              "access": {"download": "world"}
            }
          JSON
        end

        it 'does not include an uploadDate' do
          expect(schema_dot_org).not_to have_key('uploadDate')
        end
      end
    end
  end
end
