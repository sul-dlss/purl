require 'rails_helper'

RSpec.describe 'IIIF v2 manifests' do
  let(:json) { response.parsed_body }

  context 'with a map' do
    it 'is successful' do
      get '/bb157hs6068/iiif/manifest'

      expect(json['@context']).to eq 'http://iiif.io/api/presentation/2/context.json'
      expect(json['label']).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
      expect(json['description']).to eq 'Tom.1. No.9. (top right).'
      expect(json['attribution']).to start_with 'This work has been identified as being free of known restrictions'
      expect(json['seeAlso']['@id']).to eq 'http://www.example.com/bb157hs6068.mods'
      expect(json['thumbnail']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'
      expect(json['thumbnail']['@type']).to eq 'dctypes:Image'
      expect(json['thumbnail']['width']).to eq 400
      expect(json['thumbnail']['height']).to eq 345

      expect(json['sequences'].length).to eq 1
      canvas = json['sequences'].first['canvases'].first

      expect(canvas['height']).to eq 9040
      expect(canvas['width']).to eq 10_481

      expect(canvas['images'].length).to eq 1
      image = canvas['images'].first

      expect(image['resource']['height']).to eq 9040
      expect(image['resource']['width']).to eq 10_481
      expect(image['resource']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/full/0/default.jpg'

      expect(json['metadata'].class).to eq Array
      expect(json['metadata'].size).to eq(22) # 21 DC elements are there + the publish date + Available Online
      # rubocop:disable Layout/LineLength
      expected_metadata = [
        { 'label' => 'Available Online', 'value' => "<a href='http://www.example.com/bb157hs6068'>http://www.example.com/bb157hs6068</a>" },
        { 'label' => 'Title', 'value' => 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES DIVERS MOUVEMENS DES PLANETES ET LEURS DIVERSES REVOLUTIONS, AVEC DES REMARQUES HISTORIQUES POUR CONDUIRE A CETTE CONNOISSANCE' },
        { 'label' => 'Creator', 'value' => 'Chatelain, Henri Abraham' },
        { 'label' => 'Type', 'value' => 'map' },
        { 'label' => 'Type', 'value' => 'Digital Maps' },
        { 'label' => 'Type', 'value' => 'Early Maps' },
        { 'label' => 'Format', 'value' => '51.5 x 59.8 cm., including title along top and border, with 10 diagrams/maps and 6 columns of titled text.' },
        { 'label' => 'Description', 'value' => 'Tom.1. No.9. (top right).' },
        { 'label' => 'Description', 'value' => 'LC 548, 579; Koeman II, Cha 1,2; UCB; Ashley Baynton-Williams.' },
        { 'label' => 'Description', 'value' => 'California, with open northern edge, suggesting it may be an island and that northwest passage may exist, on 2 small hemisphere maps, each with 5 cm. diameter. First with title: Hemisphere terrestre pour faire | observer les 6 grands cercles de la sphere. Second with title: Hemisphere terrestre pour dis= tinguer les 4 petits cercles, et les 5 zo.' },
        { 'label' => 'Description', 'value' => "The larger diagrams are entitled: Le monde selon l'hypothese de copernic et la disposition des planetes ala naissance de Louis XIV, Sphere artificielle, Sisteme de Copernic sur les divers mouvemens des planetes, Sisteme de Ticho Brahe,Sisteme de Ptolomée, Idee generale pour faire comprendre les divers signes que la terre parcourt autour du soleil qui servent a regler les saisons (celestial chart)." },
        { 'label' => 'Description', 'value' => "The text is entitled: Remarque sur les divers mouvemens de la terre, Remarque sur le mouvemens et l'arrangement des planetes, Remarque sur la sphere, Remarque sur la maniere dont se font les saisons, Suite de la remarque sur la sphere, Conclusion et reflection morale, Comment l'hypothese de Copernic est conforme aux loix du mouvemens et de la nature, Inconveniens et difficultez qui resultent des sistemes de Ptolemeé et Ticho Brahe." },
        { 'label' => 'Description', 'value' => "First issued in his: Atlas historique, ou nouvelle introduction a l'histoire , à la chronologie & à la géographie ancienne & moderne ... -- Amsterdam. 1705. Reissued in 1721 (with imprint as above)." },
        { 'label' => 'Description', 'value' => '[Henry Abraham Châtelain].' },
        { 'label' => 'Subject', 'value' => 'Astronomy--Charts, diagrams, etc' },
        { 'label' => 'Subject', 'value' => 'California as an island--Maps' },
        { 'label' => 'Coverage', 'value' => 'W 180° --E 180°/N 85° --S 85°' },
        { 'label' => 'Date', 'value' => '1721' },
        { 'label' => 'Identifier', 'value' => '1040' },
        { 'label' => 'Identifier', 'value' => 'https://purl.stanford.edu/bb157hs6068' },
        { 'label' => 'Relation', 'value' => 'The Glen McLaughlin Map Collection of California as an Island' },
        { 'label' => 'PublishDate', 'value' => '2025-03-11T20:56:17Z' }
      ]
      # rubocop:enable Layout/LineLength
      expect(json['metadata']).to eq(expected_metadata)
    end
  end

  context 'with an image' do
    it 'includes the representative thumbnail as part of the image sequence' do
      get '/rf433wv2584/iiif/manifest'

      expect(json['thumbnail']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/rf433wv2584%2F9082000/full/!400,400/0/default.jpg'

      expect(json['sequences'].length).to eq 1
      canvas = json['sequences'].first['canvases'].first
      expect(canvas['images'].length).to eq 1
      image = canvas['images'].first
      expect(image['resource']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/rf433wv2584%2F9082000/full/full/0/default.jpg'
    end

    it 'includes canvas rendering of jp2 if downloadable' do
      get '/bb157hs6068/iiif/manifest'

      canvas = json['sequences'].first['canvases'].first
      expect(canvas['rendering'].first['label']).to eq 'Original source file (17 MB)'
    end

    it 'does not include canvas rendering if jp2 is not downloadable' do
      get '/rf433wv2584/iiif/manifest'

      canvas = json['sequences'].first['canvases'].first
      expect(canvas['rendering']).to be_nil
    end

    it 'includes authorization services for a Stanford-only image' do
      get '/bb001dq8600/iiif/manifest'

      expect(json['sequences'].length).to eq 1
      canvas = json['sequences'].first['canvases'].first
      expect(canvas['images'].length).to eq 1
      image = canvas['images'].first

      service = image['resource']['service']
      expect(service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/login'

      login_service = service['service'].detect { |x| x['profile'] == 'http://iiif.io/api/auth/1/login' }
      expect(login_service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/token'
      expect(login_service['label']).to eq 'Log in to access all available features.'
      expect(login_service['confirmLabel']).to eq 'Login'
      expect(login_service['failureHeader']).to eq 'Unable to authenticate'
      expect(login_service['failureDescription']).to eq 'The authentication serv' \
                                                        'ice cannot be reached. If your browser is configured to block pop-up wi' \
                                                        'ndows, try allowing pop-up windows for this site before attempting to l' \
                                                        'og in again.'
    end

    it 'provides otherContent for annotations that exist in an image resource' do
      get '/hx163dc5225/iiif/manifest'

      expect(json.dig('sequences', 0, 'canvases', 7, 'otherContent')).to eq [
        {
          '@id' => 'http://www.example.com/hx163dc5225/iiif/annotationList/hx163dc5225_9',
          '@type' => 'sc:AnnotationList'
        }
      ]
    end

    context 'with a location restricted image' do
      let(:druid) { 'bb361mj1737' }

      it 'generates a IIIF v2 manifest that includes location authentication information' do
        get "/#{druid}/iiif/manifest"
        expect(response).to have_http_status(:ok)

        external_interaction_service = json['sequences'].first['canvases'].first['images'].first['resource']['service']['service'].first
        expect(external_interaction_service['profile']).to eq 'http://iiif.io/api/auth/1/external'
        expect(external_interaction_service['label']).to eq 'External Authentication Required'
        expect(external_interaction_service['failureHeader']).to eq 'Restricted Material'
        expect(external_interaction_service['failureDescription']).to eq 'Restricted content cannot be accessed from your location'
        expect(external_interaction_service['service'].first['@id']).to eq "#{Settings.stacks.url}/image/iiif/token"
        expect(external_interaction_service['service'].first['profile']).to eq 'http://iiif.io/api/auth/1/token'
      end
    end
  end

  context 'with a book' do
    it 'includes viewing direction when viewing direction is defined' do
      get '/yr183sf1341/iiif/manifest'

      expect(json['sequences'].first['viewingDirection']).to eq 'right-to-left'
    end

    it 'uses left-to-right as default viewing direction if viewing direction is not defined' do
      get '/rp193xx6845/iiif/manifest'

      expect(json['sequences'].first['viewingDirection']).to eq('left-to-right')
    end

    it 'properly decodes XML entities into their UTF-8 characters' do
      get '/bb737zp0787/iiif/manifest'

      expect(json['attribution']).to eq 'Property rights reside with the repository. Copyright © Stanford University. All Rights Reserved.'
    end

    it 'suppresses sequences for dark resources' do
      get '/zm796xp7877/iiif/manifest'

      expect(json['sequences'].first['canvases'].length).to be 249
    end

    it 'publishes IIIF manifests for books with image constituents' do
      get '/zf119tw4418/iiif/manifest'

      expect(json['sequences'].length).to eq 1
      expect(json['metadata'].length).to eq 29
    end

    it 'does not publish services for pages without OCR content' do
      get '/rp193xx6845/iiif/manifest'

      expect(json).not_to have_key 'service'
    end

    it 'publishes IIIF Content Search API and seeAlso for pages with OCR content' do
      get '/bb737zp0787/iiif/manifest'

      expect(json['service'].first).to match '@context' => 'http://iiif.io/api/search/1/context.json',
                                             '@id' => 'http://example.com/content_search/bb737zp0787/search',
                                             'profile' => 'http://iiif.io/api/search/1/search',
                                             'label' => 'Search within this manifest'

      expect(json['sequences'].first['canvases'].first['seeAlso']).to eq [
        {
          '@id' => 'https://stacks.stanford.edu/file/bb737zp0787/bb737zp0787_04_0002.xml',
          'format' => 'application/xml',
          'label' => 'OCR text',
          'profile' => 'http://www.loc.gov/standards/alto/ns-v2#'
        }
      ]
    end

    it 'does not advertise an IIIF Content Search API for pages with stanford-only OCR content' do
      get '/bf995rh7184/iiif/manifest'

      expect(json).not_to include('service')
    end

    it 'does not advertise downloadable files for stanford-only no-download content' do
      get '/bf995rh7184/iiif/manifest'

      expect(json['sequences'].first).not_to include 'rendering'
    end

    it 'does not advertise an IIIF Content Search API for pages with no-download OCR content' do
      get '/bf385jz2076/iiif/manifest'

      expect(json).not_to include('service')
    end

    it 'publishes a rendering section for objects with additional resources' do
      get '/zf119tw4418/iiif/manifest'

      rendering = json['sequences'].first['rendering']
      expect(rendering).to include(
        '@id' => 'https://stacks.stanford.edu/file/zf119tw4418/zf119tw4418_31_0000.pdf',
        'label' => 'Download Full PDF',
        'format' => 'application/pdf'
      )
    end
  end

  # Virtual objects consist of a parent object and children objects who hold the file resources
  context 'with virtual objects' do
    describe 'first child object' do
      let(:druid) { 'cg767mn6478' }

      it 'generates a correct manifest' do
        get "/#{druid}/iiif/manifest"
        expect(response).to have_http_status(:ok)

        expect(json['label']).to start_with '(Covers to) Carey\'s American Atlas'
        expect(json['sequences'].length).to eq 1
        expect(json['sequences'].first['canvases'].length).to eq 1

        canvas = json['sequences'].first['canvases'].first
        expect(canvas['images'].length).to eq 1
        expect(canvas['label']).to eq 'Image 1'

        image = canvas['images'].first
        expect(image['resource']['@id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/full/0/default.jpg'
        expect(image['resource']['height']).to eq 4747
        expect(image['resource']['width']).to eq 6475
      end
    end

    describe 'second child object' do
      let(:druid) { 'jw923xn5254' }

      it 'generates a correct manifest' do
        get "/#{druid}/iiif/manifest"
        expect(response).to have_http_status(:ok)

        expect(json['label']).to start_with '(Title Page to) Carey\'s American Atlas'
        expect(json['sequences'].length).to eq 1
        expect(json['sequences'].first['canvases'].length).to eq 1

        canvas = json['sequences'].first['canvases'].first
        expect(canvas['images'].length).to eq 1
        expect(canvas['label']).to eq 'Image 1'

        image = canvas['images'].first
        expect(image['resource']['@id']).to end_with '/image/iiif/jw923xn5254%2F2542B/full/full/0/default.jpg'
        expect(image['resource']['height']).to eq 4675
        expect(image['resource']['width']).to eq 3139
      end
    end

    describe 'parent object' do
      let(:druid) { 'hj097bm8879' }

      it 'generates a correct manifest' do
        get "/#{druid}/iiif/manifest"
        expect(response).to have_http_status(:ok)

        expect(json['label']).to start_with 'Carey\'s American Atlas'
        expect(json['thumbnail']['@id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/!400,400/0/default.jpg' # first child
        expect(json['sequences'].length).to eq 1
        expect(json['sequences'].first['canvases'].length).to eq 23

        canvas = json['sequences'].first['canvases'][0]
        expect(canvas['label']).to start_with "(Covers to) Carey's American Atlas:"

        expect(canvas['images'].length).to eq 1
        image = canvas['images'].first
        expect(image['resource']['@id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/full/0/default.jpg' # first child
        expect(image['resource']['height']).to eq 4747
        expect(image['resource']['width']).to eq 6475

        canvas = json['sequences'].first['canvases'][1]
        expect(canvas['label']).to start_with "(Title Page to) Carey's American Atlas:"

        expect(canvas['images'].length).to eq 1
        image = canvas['images'].first
        expect(image['resource']['@id']).to end_with '/image/iiif/jw923xn5254%2F2542B/full/full/0/default.jpg' # second child
        expect(image['resource']['height']).to eq 4675
        expect(image['resource']['width']).to eq 3139
      end
    end
  end
end
