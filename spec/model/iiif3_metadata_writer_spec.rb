# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Iiif3MetadataWriter do
  let(:doi) { nil }
  let(:metadata_writer) do
    described_class.new(cocina_descriptive: cocina_descriptive,
                        collection_title: 'viewer testing',
                        published_date: '2025-02-24T15:55:53Z',
                        cocina_display:)
  end

  let(:cocina_display) { CocinaDisplay::CocinaRecord.new({ 'identification' => { 'doi' => doi }, 'description' => cocina_descriptive }) }

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
        expect(metadata.find { it['label'][:en] == ['Creator'] }['value'][:en]).to eq ['Author, First']
        expect(metadata.find { it['label'][:en] == ['Contributor'] }['value'][:en]).to eq ['contributor, Second (compiler)']
        expect(metadata.find { it['label'][:en] == ['Type'] }['value'][:en]).to eq ['Text', 'Policy brief']
        expect(metadata.find { it['label'][:en] == ['Abstract'] }['value'][:en]).to eq ['This is the abstract field']
        expect(metadata.find { it['label'][:en] == ['Subject'] }['value'][:en]).to eq ['keyword']
        expect(metadata.find { it['label'][:en] == ['Date'] }['value'][:en]).to eq ['February 20, 2025', 'April  5, 2024', 'January  3, 2025']
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
        expect(metadata.find { it['label'][:en] == ['Type'] }['value'][:en]).to eq ['Map', 'Digital Maps', 'Early Maps']
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

    context 'with no email for contact, structural dates' do
      # description fields taken from yh887qk5737
      let(:cocina_descriptive) do
        {

          'event' => [
            {
              'date' => [
                {
                  'structuredValue' => [
                    {
                      'value' => '1930',
                      'type' => 'start',
                      'status' => 'primary'
                    },
                    {

                      'value' => '1989',
                      'type' => 'end'
                    }
                  ],
                  'type' => 'creation',
                  'qualifier' => 'approximate'
                }
              ]
            }
          ],

          'access' => {
            'accessContact' => [
              {
                'value' => 'Stanford University. Libraries. Department of Special Collections and University Archives',
                'type' => 'repository'
              }
            ]
          }

        }
      end

      it 'extracts the date and contact correctly' do
        expect(metadata.find { it['label'][:en] == ['Date'] }['value'][:en]).to eq ['1930 - 1989']
        expect(metadata.find { it['label'][:en] == ['Contact'] }).to be_nil
      end
    end

    context 'with structured contributor name, that is not forename, surname and a structured title' do
      let(:cocina_descriptive) do
        {
          'title' => [
            { 'structuredValue' =>
             [{
               'value' => 'Erzherzog Johann; ein Charakterbild',
               'type' => 'main title'
             },
              {
                'value' => 'mit Beiträgen zur Geschichte der Begründung der zweiten Dynastie Bulgariens nach authentischen Quellen und Briefen des Erzherzogs',
                'type' => 'subtitle'
              }],
              'status' => 'primary' }
          ],
          'contributor' =>
           [{ 'name' =>
              [{ 'structuredValue' =>
                 [{
                   'value' => 'Pollak, Heinrich',
                   'type' => 'name'
                 },
                  {
                    'value' => '1835?-1908',
                    'type' => 'life dates'
                  }] }],
              'type' => 'person',
              'status' => 'primary' },
            { 'name' =>
              [{ 'structuredValue' =>
                 [{
                   'value' => 'John Salvator',
                   'type' => 'name'
                 },
                  {
                    'value' => 'Archduke of Austria',
                    'type' => 'term of address'
                  },
                  {
                    'value' => '1852-1890',
                    'type' => 'life dates'
                  }] }],
              'type' => 'person' }]
        }
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Title']
        end['value'][:en]).to eq ['Erzherzog Johann; ein Charakterbild : mit Beiträgen zur Geschichte ' \
                                  'der Begründung der zweiten Dynastie Bulgariens nach authentischen ' \
                                  'Quellen und Briefen des Erzherzogs']
        expect(metadata.find do
          it['label'][:en] == ['Contributor']
        end['value'][:en]).to eq ['Pollak, Heinrich, 1835?-1908', 'John Salvator, Archduke of Austria, 1852-1890']
      end
    end

    context 'with extent and map coordinates' do
      let(:cocina_descriptive) do
        PurlResource.find('bb157hs6068').version(:head).cocina['description']
      end

      it 'extracts the metadata' do
        expect(metadata.as_json).to eq [
          { 'label' => { 'en' => ['Available Online'] },
            'value' => { 'en' => ["<a href='https://purl.stanford.edu/bb157hs6068'>https://purl.stanford.edu/bb157hs6068</a>"] } },
          { 'label' => { 'en' => ['Title'] },
            'value' => { 'en' => ['NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES DIVERS MOUVEMENS DES PLANETES ET LEURS DIVERSES REVOLUTIONS, ' \
                                  'AVEC DES REMARQUES HISTORIQUES POUR CONDUIRE A CETTE CONNOISSANCE'] } },
          { 'label' => { 'en' => ['Creator'] }, 'value' => { 'en' => ['Chatelain, Henri Abraham'] } },
          { 'label' => { 'en' => ['Type'] }, 'value' => { 'en' => ['Map', 'Digital Maps', 'Early Maps'] } },
          { 'label' => { 'en' => ['Format'] },
            'value' => { 'en' => ['51.5 x 59.8 cm., including title along top and border, with 10 diagrams/maps and 6 columns of titled text.'] } },
          { 'label' => { 'en' => ['Description'] }, 'value' => { 'en' => [
            'Tom.1. No.9. (top right).',
            'California, with open northern edge, suggesting it may be an island and that northwest passage may exist, on 2 small hemisphere maps, ' \
            'each with 5 cm. diameter. First with title: Hemisphere terrestre pour faire | observer les 6 grands cercles de la sphere. Second with title: ' \
            'Hemisphere terrestre pour dis= tinguer les 4 petits cercles, et les 5 zo.',
            "The larger diagrams are entitled: Le monde selon l'hypothese de copernic et la disposition des planetes ala naissance de Louis XIV, " \
            'Sphere artificielle, Sisteme de Copernic sur les divers mouvemens des planetes, Sisteme de Ticho Brahe,Sisteme de Ptolomée, ' \
            'Idee generale pour faire comprendre les divers signes que la terre parcourt autour du soleil qui servent a regler les saisons (celestial chart).',
            "The text is entitled: Remarque sur les divers mouvemens de la terre, Remarque sur le mouvemens et l'arrangement des planetes, " \
            'Remarque sur la sphere, Remarque sur la maniere dont se font les saisons, Suite de la remarque sur la sphere, Conclusion et reflection morale, ' \
            "Comment l'hypothese de Copernic est conforme aux loix du mouvemens et de la nature, Inconveniens et difficultez qui resultent des sistemes " \
            'de Ptolemeé et Ticho Brahe.'
          ] } },
          { 'label' => { 'en' => ['References'] },
            'value' =>
                             { 'en' =>
                               ['LC 548, 579; Koeman II, Cha 1,2; UCB; Ashley Baynton-Williams.'] } },
          { 'label' => { 'en' => ['Publications'] },
            'value' =>
                    { 'en' =>
                      ["First issued in his: Atlas historique, ou nouvelle introduction a l'histoire , à la chronologie & à la géographie ancienne & moderne " \
                       '... -- Amsterdam. 1705. Reissued in 1721 (with imprint as above).'] } },
          { 'label' => { 'en' => ['Statement of responsibility'] },
            'value' => { 'en' => ['[Henry Abraham Châtelain].'] } },
          { 'label' => { 'en' => ['Subject'] }, 'value' => { 'en' => ['Astronomy--Charts, diagrams, etc', 'California as an island--Maps'] } },
          { 'label' => { 'en' => ['Coverage'] }, 'value' => { 'en' => ['W 180° --E 180°/N 85° --S 85°'] } },
          { 'label' => { 'en' => ['Date'] }, 'value' => { 'en' => ['1721'] } },
          { 'label' => { 'en' => ['Identifier'] }, 'value' => { 'en' => ['1040', 'https://purl.stanford.edu/bb157hs6068'] } },
          { 'label' => { 'en' => ['Relation'] }, 'value' => { 'en' => ['viewer testing'] } },
          { 'label' => { 'en' => ['PublishDate'] }, 'value' => { 'en' => ['2025-02-24T15:55:53Z'] } }
        ]
      end
    end

    context 'with map scale and coordinates' do
      let(:cocina_descriptive) do
        {
          'subject' => [{ 'value' => 'America--Maps', 'type' => 'topic', 'source' => { 'uri' => 'http => //id.loc.gov/authorities/subjects/sh85004277' } },
                        { 'value' => 'California as an island--Maps', 'type' => 'topic' },
                        { 'value' => 'W 160° --E 20°/N 90° --S 90°', 'type' => 'map coordinates' }],
          'form' => [{ 'type' => 'genre', 'value' => 'map' },
                     { 'source' => { 'value' => 'MODS resource types' }, 'type' => 'resource type', 'value' => 'cartographic' },
                     { 'type' => 'extent', 'value' => '22.5 x 31.7 cm., 22.5 x 33.1 cm. including border.' },
                     { 'type' => 'map scale', 'value' => '[ca.1 => 60,000,000].' }]
        }
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Coverage']
        end['value'][:en]).to eq ['[ca.1 => 60,000,000].', 'W 160° --E 20°/N 90° --S 90°']
      end
    end

    context 'with language' do
      let(:cocina_descriptive) do
        {
          'language' =>
          [{
            'code' => 'eng',
            'source' => { 'code' => 'iso639-2b' },
            'structuredValue' => []
          }]
        }
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Language']
        end['value'][:en]).to eq ['English']
      end
    end

    context 'with nested subject' do
      let(:cocina_descriptive) do
        {
          'subject' =>
          [{
            'type' => 'place',
            'code' => 'n-us',
            'source' => { 'code' => 'marcgac' }
          },
           { 'structuredValue' =>
             [{ 'structuredValue' =>
                [{ 'value' => 'United States' },
                 { 'value' => 'Department of Energy' },
                 { 'value' => 'Office of Inspector General' }],
                'type' => 'organization' },
              {
                'value' => 'Auditing',
                'type' => 'topic'
              },
              {
                'value' => 'Statistics',
                'type' => 'genre'
              },
              {
                'value' => 'Periodicals',
                'type' => 'genre'
              }],
             'source' => { 'code' => 'lcsh', 'note' => [] } }]
        }
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Subject']
        end['value'][:en]).to eq ['United States, Department of Energy, Office of Inspector General -- Auditing -- Statistics -- Periodicals']
      end
    end

    context 'with table of contents in notes' do
      let(:cocina_descriptive) do
        PurlResource.find('bc854fy5899').version(:head).cocina['description']
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Contents']
        end['value'][:en]).to include('Of the leaven of pharisees')
      end
    end

    context 'with publisher' do
      let(:cocina_descriptive) do
        PurlResource.find('zf119tw4418').version(:head).cocina['description']
      end

      it 'extracts the metadata' do
        expect(metadata.find do
          it['label'][:en] == ['Publisher']
        end['value'][:en]).to eq ['Dept. of Energy, Office of Inspector General']
      end
    end

    context 'when different identifier formations' do
      # dn665vh1697 has lccn
      # bb157hs6068 has local number
      let(:cocina_descriptive) do
        {
          'identifier' => [
            { 'value' => '30003962', 'type' => 'LCCN', 'source' => { 'code' => 'lccn', 'note' => [] } },
            { 'value' => 'localnumber', 'type' => 'local', 'source' => { 'code' => 'local' } },
            { 'value' => 'nosourceident' }
          ]
        }
      end

      it 'extracts all the identifiers correctly' do
        expect(metadata.find { it['label'][:en] == ['Identifier'] }['value'][:en]).to eq ['lccn: 30003962', 'localnumber', 'nosourceident']
      end
    end
  end
end
