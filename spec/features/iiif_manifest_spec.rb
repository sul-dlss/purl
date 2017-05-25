require 'rails_helper'

describe 'IIIF manifests' do
  it 'works' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['@context']).to eq 'http://iiif.io/api/presentation/2/context.json'
    expect(json['label']).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
    expect(json['description']).to eq 'Tom.1. No.9. (top right).'
    expect(json['attribution']).to start_with 'This work has been identified as being free of known restrictions'
    expect(json['seeAlso']['@id']).to eq 'http://www.example.com/bb157hs6068.mods'
    expect(json['thumbnail']['@id']).to eq 'http://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'

    expect(json['sequences'].length).to eq 1
    canvas = json['sequences'].first['canvases'].first

    expect(canvas['height']).to eq 9040
    expect(canvas['width']).to eq 10_481

    expect(canvas['images'].length).to eq 1
    image = canvas['images'].first

    expect(image['resource']['height']).to eq 9040
    expect(image['resource']['width']).to eq 10_481
    expect(image['resource']['@id']).to eq 'http://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/full/0/default.jpg'

    expect(json['metadata'].class).to eq Array
    expect(json['metadata'].size).to eq(21) # 20 DC elements are there plus the publish date
    # rubocop:disable Metrics/LineLength
    expected_dc_metadata = [
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
    # rubocop:enable Metrics/LineLength
    expect(json['metadata']).to eq(expected_dc_metadata)
  end

  it 'has the correct @id value given the url the manifest is being requested under' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['@id']).to match %r{/bb157hs6068/iiif/manifest.json$}

    visit '/bb157hs6068/iiif/manifest'
    json = JSON.parse(page.body)

    expect(json['@id']).to match %r{/bb157hs6068/iiif/manifest$}
  end

  it 'includes a representative thumbnail' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['thumbnail']['@id']).to eq 'http://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'
    expect(json['thumbnail']['@type']).to eq 'dctypes:Image'
  end

  it 'includes authorization services for a Stanford-only image' do
    visit '/py305sy7961/iiif/manifest.json'
    json = JSON.parse(page.body)
    expect(json['sequences'].length).to eq 1
    canvas = json['sequences'].first['canvases'].first
    expect(canvas['images'].length).to eq 1
    image = canvas['images'].first

    service = image['resource']['service']
    expect(service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/0/login'

    login_service = service['service'].detect { |x| x['profile'] == 'http://iiif.io/api/auth/0/login' }
    expect(login_service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/0/token'
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
    expect(json['metadata'].length).to eq 28
  end

  # Virtual objects consist of a parent object and children objects who hold the file resources
  context 'virtual objects' do
    before :each do
      # we fetch the body of the public xml and mods from the local fixtures folder rather than the network
      mods_body = File.read(File.join(Settings.document_cache_root, Dor::Util.create_pair_tree(druid), 'mods'))
      public_xml_body = File.read(File.join(Settings.document_cache_root, Dor::Util.create_pair_tree(druid), 'public'))
      allow_any_instance_of(PurlResource).to receive(:mods_resource).and_return(double(success?: true, body: mods_body))
      allow_any_instance_of(PurlResource).to receive(:public_xml_resource).and_return(double(success?: true, body: public_xml_body))
    end

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
end
