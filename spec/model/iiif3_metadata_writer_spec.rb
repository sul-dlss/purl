require 'rails_helper'

RSpec.describe Iiif3MetadataWriter do
  let(:doi) { nil }
  let(:metadata_writer) do
    described_class.new(cocina_descriptive: cocina_descriptive,
                        collection_title: 'viewer testing',
                        published_date: '2025-02-24T15:55:53Z',
                        doi:)
  end

  describe '#write' do
    subject(:metadata) { metadata_writer.write }

    context 'with h2 style data' do
      let(:doi) { '10.80343/zw438wf4318' }
      let(:cocina_descriptive) do
        {
          'title' => [
            {
              'value' => 'H2 title field'
            }
          ],
          'contributor' => [
            {
              'name' => [
                {
                  'structuredValue' => [
                    {
                      'value' => 'First',
                      'type' => 'forename'
                    },
                    {
                      'value' => 'Author',
                      'type' => 'surname'
                    }
                  ]
                }
              ],
              'type' => 'person',
              'status' => 'primary',
              'role' => [
                {
                  'value' => 'author',
                  'code' => 'aut',
                  'uri' => 'http://id.loc.gov/vocabulary/relators/aut',
                  'source' => {
                    'code' => 'marcrelator',
                    'uri' => 'http://id.loc.gov/vocabulary/relators/'
                  }
                }
              ]
            },
            {
              'name' => [
                {
                  'structuredValue' => [
                    {
                      'value' => 'Second',
                      'type' => 'forename'
                    },
                    {
                      'value' => 'contributor',
                      'type' => 'surname'
                    }
                  ]
                }
              ],
              'type' => 'person',
              'role' => [
                {
                  'value' => 'compiler',
                  'code' => 'com',
                  'uri' => 'http://id.loc.gov/vocabulary/relators/com',
                  'source' => {
                    'code' => 'marcrelator',
                    'uri' => 'http://id.loc.gov/vocabulary/relators/'
                  }
                }
              ],
              'note' => [
                {
                  'value' => 'false',
                  'type' => 'citation status'
                }
              ]
            }
          ],
          'event' => [
            {
              'type' => 'deposit',
              'date' => [
                {
                  'value' => '2025-02-20',
                  'type' => 'publication',
                  'encoding' => {
                    'code' => 'edtf'
                  }
                }
              ]
            },
            {
              'type' => 'creation',
              'date' => [
                {
                  'value' => '2024-04-05',
                  'type' => 'creation',
                  'encoding' => {
                    'code' => 'edtf'
                  }
                }
              ]
            },
            {
              'type' => 'publication',
              'date' => [
                {
                  'value' => '2025-01-03',
                  'type' => 'publication',
                  status: 'primary',
                  'encoding' => {
                    'code' => 'edtf'
                  }
                }
              ]
            }
          ],
          'form' => [
            {
              'structuredValue' => [
                {
                  'value' => 'Text',
                  'type' => 'type'
                },
                {
                  'value' => 'Policy brief',
                  'type' => 'subtype'
                }
              ],
              'type' => 'resource type',
              'source' => {
                'value' => 'Stanford self-deposit resource types',
                'note' => []
              }
            },
            {
              'value' => 'text',
              'type' => 'resource type',
              'source' => {
                'value' => 'MODS resource types'
              }
            },
            {
              'value' => 'Text',
              'type' => 'resource type',
              'source' => {
                'value' => 'DataCite resource types'
              }
            }
          ],
          'note' => [
            {
              'value' => 'This is the abstract field',
              'type' => 'abstract'
            },
            {
              'value' => 'This is the citation',
              'type' => 'preferred citation'
            }
          ],
          'subject' => [
            {
              'value' => 'keyword',
              'type' => 'topic'
            },
            {
              'value' => 'Another neat tool',
              'type' => 'title',
              'uri' => 'http://id.worldcat.org/fast/1397145/',
              'source' => {
                'code' => 'fast',
                'uri' => 'http://id.worldcat.org/fast/'
              }
            }
          ],
          'access' => {
            'accessContact' => [
              {
                'value' => 'bergeraj@stanford.edu',
                'type' => 'email',
                'displayLabel' => 'Contact'
              }
            ]
          },
          'relatedResource' => [
            {
              'title' => [
                {
                  'value' => 'Just a related link'
                }
              ],
              'access' => {
                'url' => [
                  {
                    'value' => 'https://argo-stage.stanford.edu/view/druid:gm804vr8973'
                  }
                ]
              }
            },
            {
              'note' => [
                {
                  'value' => 'A citation of a related published work, with a URL https://argo.stanford.edu/view/gq661wq7355',
                  'type' => 'preferred citation'
                }
              ]
            }
          ],
          'adminMetadata' => {
            'event' => [
              {
                'type' => 'creation',
                'date' => [
                  {
                    'value' => '2025-02-20',
                    'encoding' => {
                      'code' => 'edtf'
                    }
                  }
                ]
              }
            ],
            'language' => [],
            'note' => [
              {
                'value' => 'Metadata created by user via Stanford self-deposit application',
                'type' => 'record origin'
              }
            ]
          },
          'purl' => 'https://sul-purl-stage.stanford.edu/zw438wf4318'
        }
      end

      it 'extracts the metadata' do
        expect(metadata.find { it['label'][:en] == ['Available Online'] }['value'][:en]).to eq ["<a href='https://sul-purl-stage.stanford.edu/zw438wf4318'>https://sul-purl-stage.stanford.edu/zw438wf4318</a>"]
        expect(metadata.find { it['label'][:en] == ['Title'] }['value'][:en]).to eq ['H2 title field']
        expect(metadata.find { it['label'][:en] == ['Contributor'] }['value'][:en]).to eq ['Author, First (author)', 'contributor, Second (compiler)']
        expect(metadata.find { it['label'][:en] == ['Type'] }['value'][:en]).to eq ['Text', 'Policy brief']
        expect(metadata.find { it['label'][:en] == ['Abstract'] }['value'][:en]).to eq ['This is the abstract field']
        expect(metadata.find { it['label'][:en] == ['Subject'] }['value'][:en]).to eq ['keyword']
        expect(metadata.find { it['label'][:en] == ['Date'] }['value'][:en]).to eq %w[2025-02-20 2024-04-05 2025-01-03]
        expect(metadata.find { it['label'][:en] == ['Identifier'] }['value'][:en]).to eq ['https://sul-purl-stage.stanford.edu/zw438wf4318', 'doi: https://doi.org/10.80343/zw438wf4318']
        expect(metadata.find { it['label'][:en] == ['Relation'] }['value'][:en]).to eq ['viewer testing']
        expect(metadata.find { it['label'][:en] == ['Preferred citation'] }['value'][:en]).to eq ['This is the citation']
        expect(metadata.find { it['label'][:en] == ['Contact'] }['value'][:en]).to eq ['bergeraj@stanford.edu']
        expect(metadata.find { it['label'][:en] == ['PublishDate'] }['value'][:en]).to eq ['2025-02-24T15:55:53Z']
      end
    end

    context 'with digital collections style data' do
      let(:cocina_descriptive) do
        PurlResource.find('bb157hs6068').version(:head).cocina['description']
      end

      it 'extracts the metadata' do
        expect(metadata.find { it['label'][:en] == ['Available Online'] }['value'][:en]).to eq ["<a href='https://purl.stanford.edu/bb157hs6068'>https://purl.stanford.edu/bb157hs6068</a>"]
        expect(metadata.find do
          it['label'][:en] == ['Title']
        end['value'][:en]).to eq ['NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES DIVERS MOUVEMENS DES PLANETES ET LEURS DIVERSES REVOLUTIONS, ' \
                                  'AVEC DES REMARQUES HISTORIQUES POUR CONDUIRE A CETTE CONNOISSANCE']
        expect(metadata.find { it['label'][:en] == ['Creator'] }['value'][:en]).to eq ['Chatelain, Henri Abraham']
        expect(metadata.find { it['label'][:en] == ['Type'] }['value'][:en]).to eq ['map', 'Digital Maps', 'Early Maps']
        expect(metadata.find { it['label'][:en] == ['Subject'] }['value'][:en]).to eq ['Astronomy--Charts, diagrams, etc', 'California as an island--Maps']
        expect(metadata.find { it['label'][:en] == ['Date'] }['value'][:en]).to eq %w[1721]
        expect(metadata.find { it['label'][:en] == ['Identifier'] }['value'][:en]).to eq ['1040', 'https://purl.stanford.edu/bb157hs6068']
        expect(metadata.find { it['label'][:en] == ['Relation'] }['value'][:en]).to eq ['viewer testing']
        expect(metadata.find { it['label'][:en] == ['PublishDate'] }['value'][:en]).to eq ['2025-02-24T15:55:53Z']
        expect(metadata.find { it['label'][:en] == ['Abstract'] }).to be_nil
        expect(metadata.find { it['label'][:en] == ['Preferred citation'] }).to be_nil
        expect(metadata.find { it['label'][:en] == ['Contact'] }).to be_nil
      end
    end

    context 'with structured contributor name, that is not forename, surname and a structured title' do
      let(:cocina_descriptive) do
        PurlResource.find('bb006mf9900').version(:head).cocina['description']
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Title']
        end['value'][:en]).to eq ['Erzherzog Johann; ein Charakterbild',
                                  'mit Beiträgen zur Geschichte der Begründung der zweiten Dynastie Bulgariens nach authentischen ' \
                                  'Quellen und Briefen des Erzherzogs']
        expect(metadata.find { it['label'][:en] == ['Contributor'] }['value'][:en]).to eq ['Pollak, Heinrich', 'John Salvator']
      end
    end

    context 'with extent' do
      let(:cocina_descriptive) do
        PurlResource.find('bb157hs6068').version(:head).cocina['description']
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Format']
        end['value'][:en]).to eq ['51.5 x 59.8 cm., including title along top and border, with 10 diagrams/maps and 6 columns of titled text.']
      end
    end

    context 'with language' do
      let(:cocina_descriptive) do
        PurlResource.find('zf119tw4418').version(:head).cocina['description']
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Language']
        end['value'][:en]).to eq ['eng']
      end
    end
  end
end
