require 'rails_helper'
require 'iiif/v3/presentation' # Can we get the iiif-presentation gem to load this?

RSpec.describe 'IIIF v3 manifests' do
  it 'works' do
    visit '/bb157hs6068/iiif3/manifest'
    json = JSON.parse(page.body)

    expect(json['@context']).to include 'http://www.w3.org/ns/anno.jsonld', 'http://iiif.io/api/presentation/3/context.json'
    expect(json['label']['en'].first).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
    expect(json['summary']['en'].first).to eq 'Tom.1. No.9. (top right).'
    expect(json['requiredStatement']['value']['en'].first).to start_with 'This work has been identified as being free of known restrictions'
    expect(json['seeAlso'].first['id']).to eq 'http://www.example.com/bb157hs6068.mods'
    expect(json['thumbnail']).to be_an Array
    expect(json['thumbnail'].size).to eq 1
    expect(json['thumbnail'].first['id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068/bb157hs6068_05_0001/full/!400,400/0/default.jpg'

    expect(json['items'].length).to eq 1
    canvas = json['items'].first

    expect(canvas['height']).to eq 9040
    expect(canvas['width']).to eq 10_481

    expect(canvas['items'].length).to eq 1
    expect(canvas['items'].first['items'].length).to eq 1
    image = canvas['items'].first['items'].first
    expect(image['body']['height']).to eq 9040
    expect(image['body']['width']).to eq 10_481
    expect(image['body']['id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068/bb157hs6068_05_0001/full/full/0/default.jpg'

    expect(json['metadata'].class).to eq Array
    expect(json['metadata'].size).to eq(13) # 11 DC elements grouped by name are there + the publish date + Available Online
    # rubocop:disable Layout/LineLength
    expected_dc_metadata = [
      { 'label' => { 'en' => ['Available Online'] }, 'value' => { 'en' => ["<a href='http://www.example.com/bb157hs6068'>http://www.example.com/bb157hs6068</a>"] } },
      { 'label' => { 'en' => ['Type'] }, 'value' => { 'en' => ['map', 'Digital Maps', 'Early Maps'] } },
      { 'label' => { 'en' => ['Rights'] }, 'value' => { 'en' => ["Stanford University Libraries and Academic Information Resources - Terms of Use SULAIR Web sites are subject to Stanford University's standard Terms of Use (See http://www.stanford.edu/home/atoz/terms.html) These terms include a limited personal, non-exclusive, non-transferable license to access and use the sites, and to download - where permitted - material for personal, non-commercial, non-display use only. Please contact the University Librarian to request permission to use SULAIR Web sites and contents beyond the scope of the above license, including but not limited to republication to a group or republishing the Web site or parts of the Web site. SULAIR provides access to a variety of external databases and resources, which sites are governed by their own Terms of Use, as well as contractual access restrictions. The Terms of Use on these external sites always govern the data available there. Please consult with library staff if you have questions about data access and availability."] } },
      { 'label' => { 'en' => ['Identifier'] }, 'value' => { 'en' => ['1040'] } },
      { 'label' => { 'en' => ['Title'] }, 'value' => { 'en' => ['NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES DIVERS MOUVEMENS DES PLANETES ET LEURS DIVERSES REVOLUTIONS, AVEC DES REMARQUES HISTORIQUES POUR CONDUIRE A CETTE CONNOISSANCE'] } },
      { 'label' => { 'en' => ['Date'] }, 'value' => { 'en' => ['1721'] } },
      { 'label' => { 'en' => ['Format'] }, 'value' => { 'en' => ['51.5 x 59.8 cm., including title along top and border, with 10 diagrams/maps and 6 columns of titled text.'] } },
      { 'label' => { 'en' => ['Contributor'] }, 'value' => { 'en' => ['Chatelain, Henri Abraham'] } },
      { 'label' => { 'en' => ['Description'] }, 'value' => { 'en' => [
        'Tom.1. No.9. (top right).',
        'LC 548, 579; Koeman II, Cha 1,2; UCB; Ashley Baynton-Williams.',
        'California, with open northern edge, suggesting it may be an island and that northwest passage may exist, on 2 small hemisphere maps, each with 5 cm. diameter. First with title: Hemisphere terrestre pour faire | observer les 6 grands cercles de la sphere. Second with title: Hemisphere terrestre pour dis= tinguer les 4 petits cercles, et les 5 zo.',
        "The larger diagrams are entitled: Le monde selon l'hypothese de copernic et la disposition des planetes ala naissance de Louis XIV, Sphere artificielle, Sisteme de Copernic sur les divers mouvemens des planetes, Sisteme de Ticho Brahe,Sisteme de Ptolomée, Idee generale pour faire comprendre les divers signes que la terre parcourt autour du soleil qui servent a regler les saisons (celestial chart).",
        "The text is entitled: Remarque sur les divers mouvemens de la terre, Remarque sur le mouvemens et l'arrangement des planetes, Remarque sur la sphere, Remarque sur la maniere dont se font les saisons, Suite de la remarque sur la sphere, Conclusion et reflection morale, Comment l'hypothese de Copernic est conforme aux loix du mouvemens et de la nature, Inconveniens et difficultez qui resultent des sistemes de Ptolemeé et Ticho Brahe.",
        "First issued in his: Atlas historique, ou nouvelle introduction a l'histoire , à la chronologie & à la géographie ancienne & moderne ... -- Amsterdam. 1705. Reissued in 1721 (with imprint as above).",
        '[Henry Abraham Châtelain].'
      ] } },
      { 'label' => { 'en' => ['Subject'] }, 'value' => { 'en' => ['Astronomy--Charts, diagrams, etc', 'California as an island--Maps'] } },
      { 'label' => { 'en' => ['Coverage'] }, 'value' => { 'en' => ['(W 180° --E 180°/N 85° --S 85°)'] } },
      { 'label' => { 'en' => ['Relation'] }, 'value' => { 'en' => ['The Glen McLaughlin Map Collection of California as an Island'] } },
      { 'label' => { 'en' => ['PublishDate'] }, 'value' => { 'en' => ['2016-06-16T21:46:16Z'] } } # publish date was added
    ]
    # rubocop:enable Layout/LineLength
    expect(json['metadata']).to eq(expected_dc_metadata)
  end

  it 'includes a representative thumbnail' do
    visit '/bb157hs6068/iiif3/manifest'
    json = JSON.parse(page.body)

    expect(json['thumbnail']).to be_an Array
    expect(json['thumbnail'].size).to eq 1
    expect(json['thumbnail'].first['id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068/bb157hs6068_05_0001/full/!400,400/0/default.jpg'
    expect(json['thumbnail'].first['type']).to eq 'Image'
    expect(json['thumbnail'].first['width']).to eq 400
    expect(json['thumbnail'].first['height']).to eq 345
  end

  it 'includes viewing direction when viewing direction is defined' do
    visit '/yr183sf1341/iiif3/manifest'
    json = JSON.parse(page.body)
    expect(json['viewingDirection']).to eq 'right-to-left'
  end

  it 'uses left-to-right as default viewing direction if viewing direction is not defined' do
    visit '/py305sy7961/iiif3/manifest'
    json = JSON.parse(page.body)
    expect(json['viewingDirection']).to eq('left-to-right')
  end

  it 'includes authorization services for a Stanford-only image' do
    visit '/bb001dq8600/iiif3/manifest'
    json = JSON.parse(page.body)
    expect(json['items'].length).to eq 1
    canvas = json['items'].first
    expect(canvas['items'].first['items'].length).to eq 1
    image = canvas['items'].first['items'].first
    service = image['body']['service'].first
    expect(service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/login'

    login_service = service['service'].detect { |x| x['profile'] == 'http://iiif.io/api/auth/1/login' }
    expect(login_service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/token'
    expect(login_service['label']).to eq 'Log in to access all available features.'
    expect(login_service['confirmLabel']).to eq 'Login'
    expect(login_service['failureHeader']).to eq 'Unable to authenticate'
    expect(login_service['failureDescription']).to eq 'The authentication serv'\
      'ice cannot be reached. If your browser is configured to block pop-up wi'\
      'ndows, try allowing pop-up windows for this site before attempting to l'\
      'og in again.'
  end

  it 'includes authorization services for cdl images' do
    visit '/pg500wr6297/iiif3/manifest.json'
    json = JSON.parse(page.body)
    service = json['items'][2]['items'].first['items'].first['body']['service'].first
    expect(service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/login'

    login_service = service['service'].detect { |x| x['profile'] == 'http://iiif.io/api/auth/1/login' }
    expect(login_service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/token'
    expect(login_service['label']).to eq 'Available for checkout.'
    expect(login_service['confirmLabel']).to eq 'Checkout'
    expect(login_service['id']).to eq 'https://stacks.stanford.edu/auth/iiif/cdl/pg500wr6297/checkout'
    expect(login_service['failureHeader']).to eq 'Unable to authenticate'
    expect(login_service['failureDescription']).to eq 'The authentication serv'\
      'ice cannot be reached.'
  end

  it 'properly decodes XML entities into their UTF-8 characters' do
    visit '/bb737zp0787/iiif3/manifest'
    json = JSON.parse(page.body)
    expect(json['requiredStatement']['value']['en'].first)
      .to eq 'Property rights reside with the repository. Copyright © Stanford University. All Rights Reserved.'
  end

  it 'publishes IIIF manifests for books with image constituents' do
    visit '/zf119tw4418/iiif3/manifest'
    json = JSON.parse(page.body)

    expect(json['items'].length).to eq 58
    expect(json['metadata'].length).to eq 13
  end

  it 'does not publish services for pages without OCR content' do
    visit '/py305sy7961/iiif3/manifest'
    json = JSON.parse(page.body)

    expect(json).not_to have_key 'service'
  end

  it 'publishes IIIF Content Search API for pages with OCR content' do
    visit '/jg072yr3056/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['service'].first).to match '@context' => 'http://iiif.io/api/search/1/context.json',
                                           '@id' => 'http://example.com/content_search/jg072yr3056/search',
                                           'profile' => 'http://iiif.io/api/search/1/search',
                                           'label' => 'Search within this manifest'
  end

  # Virtual objects consist of a parent object and children objects who hold the file resources
  context 'virtual objects' do
    describe 'first child object' do
      let(:druid) { 'cg767mn6478' }

      it 'generates a correct manifest' do
        visit "/#{druid}/iiif3/manifest"
        expect(page).to have_http_status(:ok)

        json = JSON.parse(page.body)
        expect(json['label']['en'].first).to start_with '(Covers to) Carey\'s American Atlas'
        expect(json['items'].length).to eq 1

        canvas = json['items'].first
        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['label']['en'].first).to eq 'Image 1'

        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/cg767mn6478/2542A/full/full/0/default.jpg'
        expect(image['body']['height']).to eq 4747
        expect(image['body']['width']).to eq 6475
      end
    end

    describe 'second child object' do
      let(:druid) { 'jw923xn5254' }

      it 'generates a correct manifest' do
        visit "/#{druid}/iiif3/manifest"
        expect(page).to have_http_status(:ok)

        json = JSON.parse(page.body)
        expect(json['label']['en'].first).to start_with '(Title Page to) Carey\'s American Atlas'
        expect(json['items'].length).to eq 1

        canvas = json['items'].first
        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['label']['en'].first).to eq 'Image 1'

        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/jw923xn5254/2542B/full/full/0/default.jpg'
        expect(image['body']['height']).to eq 4675
        expect(image['body']['width']).to eq 3139
      end
    end

    describe 'parent object' do
      let(:druid) { 'hj097bm8879' }

      it 'generates a correct manifest' do
        visit "/#{druid}/iiif3/manifest"
        expect(page).to have_http_status(:ok)

        json = JSON.parse(page.body)
        expect(json['label']['en'].first).to start_with 'Carey\'s American Atlas'
        expect(json['thumbnail']).to be_an Array
        expect(json['thumbnail'].size).to eq 1
        expect(json['thumbnail'].first['id']).to end_with '/image/iiif/cg767mn6478/2542A/full/!400,400/0/default.jpg' # first child
        expect(json['items'].length).to eq 23

        canvas = json['items'].first
        expect(canvas['label']['en']).to start_with "Cover: Carey's American atlas."

        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/cg767mn6478/2542A/full/full/0/default.jpg' # first child
        expect(image['body']['height']).to eq 4747
        expect(image['body']['width']).to eq 6475

        canvas = json['items'].second
        expect(canvas['label']['en'].first).to start_with "Title Page: Carey's American atlas."

        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/jw923xn5254/2542B/full/full/0/default.jpg' # second child
        expect(image['body']['height']).to eq 4675
        expect(image['body']['width']).to eq 3139
      end
    end
  end

  describe 'a PDF object' do
    let(:druid) { 'bb132pr2055' }

    it 'generates a correct manifest' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)
      expect(json['label']['en'].first).to eq 'How does politics affect central banking?: evidence from the Federal Reserve'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      expect(canvas['height']).not_to be_present
      expect(canvas['width']).not_to be_present

      pdf = canvas['items'].first['items'].first
      expect(pdf['body']['id']).to eq 'https://stacks.stanford.edu/file/bb132pr2055/Puente-Thesis-Submission-augmented.pdf'
      expect(pdf['body']['format']).to eq 'application/pdf'
      expect(pdf['body']['type']).to eq 'Text'
    end
  end

  describe 'a Stanford-only PDF object' do
    let(:druid) { 'bb253gh8060' }

    it 'generates a manifest that includes the login service for the restricted file' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)
      expect(json['label']['en'].first).to eq 'Agenda'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      expect(canvas['height']).not_to be_present
      expect(canvas['width']).not_to be_present

      pdf = canvas['items'].first['items'].first
      body = pdf.fetch('body')
      expect(body['id']).to eq 'https://stacks.stanford.edu/file/bb253gh8060/SC0193_Agenda_6381_2010-10-07_001.pdf'
      expect(body['format']).to eq 'application/pdf'
      expect(body['type']).to eq 'Text'

      probe_service = body.fetch('service').first
      expect(probe_service['type']).to eq 'AuthProbeService2'
      expect(probe_service['id']).to eq 'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Ffile%2Fbb253gh8060%2FSC0193_Agenda_6381_2010-10-07_001.pdf'
      expect(probe_service['service']).to include hash_including 'type' => 'AuthAccessService2'
      expect(probe_service.dig('service', 0, 'service')).to include hash_including 'type' => 'AuthAccessTokenService2'
    end
  end

  describe 'a 3D object' do
    let(:druid) { 'hc941fm6529' }

    it 'generates a correct IIIF v3 manifest' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)

      expect(json['label']['en'].first).to start_with 'Sheep'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      expect(canvas['height']).not_to be_present
      expect(canvas['width']).not_to be_present

      obj = canvas['items'].first['items'].first
      expect(obj['body']['id']).to eq 'https://stacks.stanford.edu/file/hc941fm6529/hc941fm6529.json'
      expect(obj['body']['format']).to eq 'application/vnd.threejs+json'
      expect(obj['body']['type']).to eq 'Model'
    end
  end

  context 'when the object has no published files' do
    let(:druid) { 'bg387kw8222' }
    let(:resource) { instance_double(PurlResource, updated_at: 2.days.ago, cache_key: 'resource/xxx') }

    before do
      allow(PurlResource).to receive(:find).and_return(resource)
      allow(resource).to receive(:iiif3_manifest).and_raise(IIIF::V3::Presentation::MissingRequiredKeyError)
    end

    it 'returns 404' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:not_found)
    end
  end

  describe 'a 3D object as obj' do
    let(:druid) { 'bg387kw8222' }

    it 'only generates a single 3d resource on the canvas' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)

      expect(json['label']['en'].first).to start_with 'Department of Anthropology Bone Collection'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      expect(canvas['height']).not_to be_present
      expect(canvas['width']).not_to be_present

      obj = canvas['items'].first['items'].first
      expect(obj['body']['id']).to eq 'https://stacks.stanford.edu/file/bg387kw8222/bg387kw8222_low.obj'
      expect(obj['body']['format']).to eq 'text/plain'
      expect(obj['body']['type']).to eq 'Dataset'
    end
  end

  describe 'a location restricted image' do
    let(:druid) { 'yy816tv6021' }

    it 'generates a IIIF v3 manifest that includes location authentication information' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)
      external_interaction_service = json['items'].first['items'].first['items'].first['body']['service'].first['service'].first
      expect(external_interaction_service['profile']).to eq 'http://iiif.io/api/auth/1/external'
      expect(external_interaction_service['label']).to eq 'External Authentication Required'
      expect(external_interaction_service['failureHeader']).to eq 'Restricted Material'
      expect(external_interaction_service['failureDescription']).to eq 'Restricted content cannot be accessed from your location'
      expect(external_interaction_service['service'].first['@id']).to eq "#{Settings.stacks.url}/image/iiif/token"
      expect(external_interaction_service['service'].first['profile']).to eq 'http://iiif.io/api/auth/1/token'
    end
  end

  context 'a video object with captions' do
    let(:druid) { 'wr231qr2829' }

    it 'includes a placeholder canvas and caption annotations' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)
      canvas = json.dig('items', 0)

      expect(canvas.dig('items', 0, 'items', 0, 'body')).to include('type' => 'Video')
      expect(canvas.dig('placeholderCanvas', 'items', 0, 'items', 0, 'body')).to include(
        'type' => 'Image',
        'service' => include(hash_including('type' => 'ImageService2'))
      )
      expect(canvas.dig('annotations', 0, 'items', 0)).to include(
        'motivation' => 'supplementing',
        'body' => hash_including(
          'type' => 'Text',
          'format' => 'text/vtt'
        )
      )
    end
  end

  describe 'an object with coordinates' do
    let(:druid) { 'rp193xx6845' }

    it 'generates a correct manifest with navPlace' do
      visit "/#{druid}/iiif3/manifest"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)
      expect(json['@context']).to include 'http://iiif.io/api/extension/navplace/context.json'
      features = json['navPlace']['features']
      expect(features.length).to eq 2
      expect(features[0]['geometry'].with_indifferent_access).to match({
                                                                         "type": 'Polygon',
                                                                         "coordinates": [
                                                                           [
                                                                             ['-23.9', '71.316666'],
                                                                             ['53.6', '71.316666'],
                                                                             ['53.6', '33.5'],
                                                                             ['-23.9', '33.5'],
                                                                             ['-23.9', '71.316666']
                                                                           ]
                                                                         ]
                                                                       })
      expect(features[1]['geometry'].with_indifferent_access).to match({
                                                                         "type": 'Point',
                                                                         "coordinates": [
                                                                           '103.8',
                                                                           '-3.766666'
                                                                         ]
                                                                       })
    end
  end
end
