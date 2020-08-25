require 'rails_helper'

describe 'IIIF v2 manifests' do
  it 'works' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['@context']).to eq 'http://iiif.io/api/presentation/2/context.json'
    expect(json['label']).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
    expect(json['description']).to eq 'Tom.1. No.9. (top right).'
    expect(json['attribution']).to start_with 'This work has been identified as being free of known restrictions'
    expect(json['seeAlso']['@id']).to eq 'http://www.example.com/bb157hs6068.mods'
    expect(json['thumbnail']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'

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
    expect(json['metadata'].size).to eq(22) # 20 DC elements are there + the publish date + Available Online
    # rubocop:disable Layout/LineLength
    expected_metadata = [
      { 'label' => 'Available Online', 'value' => "<a href='http://www.example.com/bb157hs6068'>http://www.example.com/bb157hs6068</a>" },
      { 'label' => 'Type', 'value' => 'map' },
      { 'label' => 'Type', 'value' => 'Digital Maps' },
      { 'label' => 'Rights', 'value' => "Stanford University Libraries and Academic Information Resources - Terms of Use SULAIR Web sites are subject to Stanford University's standard Terms of Use (See http://www.stanford.edu/home/atoz/terms.html) These terms include a limited personal, non-exclusive, non-transferable license to access and use the sites, and to download - where permitted - material for personal, non-commercial, non-display use only. Please contact the University Librarian to request permission to use SULAIR Web sites and contents beyond the scope of the above license, including but not limited to republication to a group or republishing the Web site or parts of the Web site. SULAIR provides access to a variety of external databases and resources, which sites are governed by their own Terms of Use, as well as contractual access restrictions. The Terms of Use on these external sites always govern the data available there. Please consult with library staff if you have questions about data access and availability." },
      { 'label' => 'Identifier', 'value' => '1040' },
      { 'label' => 'Title', 'value' => 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES DIVERS MOUVEMENS DES PLANETES ET LEURS DIVERSES REVOLUTIONS, AVEC DES REMARQUES HISTORIQUES POUR CONDUIRE A CETTE CONNOISSANCE' },
      { 'label' => 'Date', 'value' => '1721' },
      { 'label' => 'Format', 'value' => '51.5 x 59.8 cm., including title along top and border, with 10 diagrams/maps and 6 columns of titled text.' },
      { 'label' => 'Contributor', 'value' => 'Chatelain, Henri Abraham' },
      { 'label' => 'Type', 'value' => 'Early Maps' },
      { 'label' => 'Description', 'value' => 'Tom.1. No.9. (top right).' },
      { 'label' => 'Description', 'value' => 'LC 548, 579; Koeman II, Cha 1,2; UCB; Ashley Baynton-Williams.' },
      { 'label' => 'Description', 'value' => 'California, with open northern edge, suggesting it may be an island and that northwest passage may exist, on 2 small hemisphere maps, each with 5 cm. diameter. First with title: Hemisphere terrestre pour faire | observer les 6 grands cercles de la sphere. Second with title: Hemisphere terrestre pour dis= tinguer les 4 petits cercles, et les 5 zo.' },
      { 'label' => 'Description', 'value' => "The larger diagrams are entitled: Le monde selon l'hypothese de copernic et la disposition des planetes ala naissance de Louis XIV, Sphere artificielle, Sisteme de Copernic sur les divers mouvemens des planetes, Sisteme de Ticho Brahe,Sisteme de Ptolomée, Idee generale pour faire comprendre les divers signes que la terre parcourt autour du soleil qui servent a regler les saisons (celestial chart)." },
      { 'label' => 'Description', 'value' => "The text is entitled: Remarque sur les divers mouvemens de la terre, Remarque sur le mouvemens et l'arrangement des planetes, Remarque sur la sphere, Remarque sur la maniere dont se font les saisons, Suite de la remarque sur la sphere, Conclusion et reflection morale, Comment l'hypothese de Copernic est conforme aux loix du mouvemens et de la nature, Inconveniens et difficultez qui resultent des sistemes de Ptolemeé et Ticho Brahe." },
      { 'label' => 'Description', 'value' => "First issued in his: Atlas historique, ou nouvelle introduction a l'histoire , à la chronologie & à la géographie ancienne & moderne ... -- Amsterdam. 1705. Reissued in 1721 (with imprint as above)." },
      { 'label' => 'Description', 'value' => '[Henry Abraham Châtelain].' },
      { 'label' => 'Subject', 'value' => 'Astronomy--Charts, diagrams, etc' },
      { 'label' => 'Subject', 'value' => 'California as an island--Maps' },
      { 'label' => 'Coverage', 'value' => '(W 180° --E 180°/N 85° --S 85°)' },
      { 'label' => 'Relation', 'value' => 'The Glen McLaughlin Map Collection of California as an Island' },
      { 'label' => 'PublishDate', 'value' => '2016-06-16T21:46:16Z' } # publish date was added
    ]
    # rubocop:enable Layout/LineLength
    expect(json['metadata']).to eq(expected_metadata)
  end

  it 'includes a representative thumbnail' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['thumbnail']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'
    expect(json['thumbnail']['@type']).to eq 'dctypes:Image'
    expect(json['thumbnail']['width']).to eq 400
    expect(json['thumbnail']['height']).to eq 345
  end

  it 'includes the representative thumbnail as part of the image sequence' do
    visit '/rf433wv2584/iiif/manifest.json'
    json = JSON.parse(page.body)
    expect(json['thumbnail']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/rf433wv2584%2F9082000/full/!400,400/0/default.jpg'

    expect(json['sequences'].length).to eq 1
    canvas = json['sequences'].first['canvases'].first
    expect(canvas['images'].length).to eq 1
    image = canvas['images'].first
    expect(image['resource']['@id']).to eq 'https://stacks.stanford.edu/image/iiif/rf433wv2584%2F9082000/full/full/0/default.jpg'
  end

  it 'includes canvas rendering of jp2 if downloadable' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)
    canvas = json['sequences'].first['canvases'].first
    expect(canvas['rendering'].first['label']).to eq 'Original source file (17 MB)'
  end

  it 'does not include canvas rendering if jp2 is not downloadable' do
    visit '/rf433wv2584/iiif/manifest.json'
    json = JSON.parse(page.body)
    canvas = json['sequences'].first['canvases'].first
    expect(canvas['rendering']).to be_nil
  end

  it 'includes viewing direction when viewing direction is defined' do
    visit '/yr183sf1341/iiif/manifest'
    json = JSON.parse(page.body)
    expect(json['sequences'].first['viewingDirection']).to eq 'right-to-left'
  end

  it 'uses left-to-right as default viewing direction if viewing direction is not defined' do
    visit '/py305sy7961/iiif/manifest'
    json = JSON.parse(page.body)
    expect(json['sequences'].first['viewingDirection']).to eq('left-to-right')
  end

  it 'includes authorization services for a Stanford-only image' do
    visit '/py305sy7961/iiif/manifest.json'
    json = JSON.parse(page.body)
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
    expect(login_service['failureDescription']).to eq 'The authentication serv'\
      'ice cannot be reached. If your browser is configured to block pop-up wi'\
      'ndows, try allowing pop-up windows for this site before attempting to l'\
      'og in again.'
  end

  it 'includes authorization services for cdl images' do
    visit '/pg500wr6297/iiif/manifest.json'
    json = JSON.parse(page.body)
    expect(json['sequences'].length).to eq 1
    canvas = json['sequences'].first['canvases'].first
    expect(canvas['images'].length).to eq 1
    image = canvas['images'].first

    service = image['resource']['service']
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
    visit '/py305sy7961/iiif/manifest.json'
    json = JSON.parse(page.body)
    expect(json['attribution']).to eq 'Property rights reside with the repository. Copyright © Stanford University. All Rights Reserved.'
  end

  it 'suppresses sequences for dark resources' do
    visit '/bc421tk1152/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['sequences'].length).to eq 1
    expect(json['sequences'].first['canvases']).to be_blank
  end

  it 'publishes IIIF manifests for books with image constituents' do
    visit '/zf119tw4418/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['sequences'].length).to eq 1
    expect(json['metadata'].length).to eq 29
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
                                           'label' => 'Search within this manifest',
                                           'service' => {
                                             '@id' => 'http://example.com/content_search/jg072yr3056/autocomplete',
                                             'profile' => 'http://iiif.io/api/search/1/autocomplete'
                                           }
  end

  it 'publishes seeAlso for canvases with OCR content' do
    visit '/jg072yr3056/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['sequences'].first['canvases'].first['seeAlso']).to eq [
      {
        '@id' => 'https://stacks.stanford.edu/file/jg072yr3056/jg072yr3056_04_0001.xml',
        'format' => 'application/xml',
        'label' => 'OCR text',
        'profile' => 'http://www.loc.gov/standards/alto/ns-v2#'
      }
    ]
  end

  it 'does not advertise an IIIF Content Search API for pages with stanford-only OCR content' do
    visit '/bf995rh7184/iiif/manifest'
    json = JSON.parse(page.body)

    expect(json).not_to include('service')
  end

  it 'does not advertise an IIIF Content Search API for pages with no-download OCR content' do
    visit '/bf385jz2076/iiif/manifest'
    json = JSON.parse(page.body)

    expect(json).not_to include('service')
  end

  it 'publishes a rendering section for objects with additional resources' do
    visit '/zf119tw4418/iiif/manifest.json'
    json = JSON.parse(page.body)

    rendering = json['sequences'].first['rendering']
    expect(rendering).to include(
      '@id' => 'https://stacks.stanford.edu/file/zf119tw4418/zf119tw4418_31_0000.pdf',
      'label' => 'Download Object 1',
      'format' => 'application/pdf'
    )
  end

  it 'does not advertise downloadable files for stanford-only no-download content' do
    visit '/bf995rh7184/iiif/manifest'
    json = JSON.parse(page.body)

    expect(json['sequences'].first).not_to include 'rendering'
  end

  # Virtual objects consist of a parent object and children objects who hold the file resources
  context 'virtual objects' do
    describe 'first child object' do
      let(:druid) { 'cg767mn6478' }

      it 'generates a correct manifest.json' do
        visit "/#{druid}/iiif/manifest.json"
        expect(page).to have_http_status(:ok)

        json = JSON.parse(page.body)
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

      it 'generates a correct manifest.json' do
        visit "/#{druid}/iiif/manifest.json"
        expect(page).to have_http_status(:ok)

        json = JSON.parse(page.body)
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

      it 'generates a correct manifest.json' do
        visit "/#{druid}/iiif/manifest.json"
        expect(page).to have_http_status(:ok)

        json = JSON.parse(page.body)
        expect(json['label']).to start_with 'Carey\'s American Atlas'
        expect(json['thumbnail']['@id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/!400,400/0/default.jpg' # first child
        expect(json['sequences'].length).to eq 1
        expect(json['sequences'].first['canvases'].length).to eq 23

        canvas = json['sequences'].first['canvases'][0]
        expect(canvas['label']).to start_with "Cover: Carey's American atlas."

        expect(canvas['images'].length).to eq 1
        image = canvas['images'].first
        expect(image['resource']['@id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/full/0/default.jpg' # first child
        expect(image['resource']['height']).to eq 4747
        expect(image['resource']['width']).to eq 6475

        canvas = json['sequences'].first['canvases'][1]
        expect(canvas['label']).to start_with "Title Page: Carey's American atlas."

        expect(canvas['images'].length).to eq 1
        image = canvas['images'].first
        expect(image['resource']['@id']).to end_with '/image/iiif/jw923xn5254%2F2542B/full/full/0/default.jpg' # second child
        expect(image['resource']['height']).to eq 4675
        expect(image['resource']['width']).to eq 3139
      end
    end
  end

  describe 'a location restricted image' do
    let(:druid) { 'bb361mj1737' }

    it 'generates a IIIF v2 manifest that includes location authentication information' do
      visit "/#{druid}/iiif/manifest.json"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)
      external_interaction_service = json['sequences'].first['canvases'].first['images'].first['resource']['service']['service'].first
      expect(external_interaction_service['profile']).to eq 'http://iiif.io/api/auth/1/external'
      expect(external_interaction_service['label']).to eq 'External Authentication Required'
      expect(external_interaction_service['failureHeader']).to eq 'Restricted Material'
      expect(external_interaction_service['failureDescription']).to eq 'Restricted content cannot be accessed from your location'
      expect(external_interaction_service['service'].first['@id']).to eq "#{Settings.stacks.url}/image/iiif/token"
      expect(external_interaction_service['service'].first['profile']).to eq 'http://iiif.io/api/auth/1/token'
    end
  end

  context 'a resource with special characters' do
    let(:druid) { 'fg019pm1396' }

    it 'generates a IIIF v2 manifest that escapes resources in urls' do
      visit "/#{druid}/iiif/manifest.json"
      expect(page).to have_http_status(:ok)

      json = JSON.parse(page.body)
      image_ids = json['sequences'].flat_map { |x| x['canvases'] }.flat_map { |x| x['images'] }.map { |x| x['resource']['@id'] }

      # handle spaces
      expect(image_ids).to include 'https://stacks.stanford.edu/image/iiif/fg019pm1396%2FJungleCat%20x/full/full/0/default.jpg'

      # handle percent signs
      expect(image_ids).to include 'https://stacks.stanford.edu/image/iiif/fg019pm1396%2FJungleCat%2520x/full/full/0/default.jpg'

      # xml escaped stuff
      expect(image_ids).to include 'https://stacks.stanford.edu/image/iiif/fg019pm1396%2FJungleCat%26x/full/full/0/default.jpg'
    end
  end
end
