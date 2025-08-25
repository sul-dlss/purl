require 'rails_helper'
require 'iiif/v3/presentation' # Can we get the iiif-presentation gem to load this?

RSpec.describe 'IIIF v3 manifests' do
  let(:json) { response.parsed_body }

  context 'when a specific version is requested' do
    it 'is successful, has correct filepaths and metadata' do
      get '/zb733jx3137/version/2/iiif3/manifest'

      expect(json['@context']).to include 'http://www.w3.org/ns/anno.jsonld', 'http://iiif.io/api/presentation/3/context.json'
      expect(json['label']['en'].first).to eq 'Testing versioning issue with the review workflow in the new application'

      # canvas urls should point to the versioned file
      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      text = canvas['items'].first['items'].first
      expect(text['body']['id']).to eq 'https://stacks.stanford.edu/v2/file/zb733jx3137/version/2/test_file_v1.pdf'

      # probe_service should also point to the versioned file
      probe_service = text['body'].fetch('service').first
      expect(probe_service['type']).to eq 'AuthProbeService2'
      expect(probe_service['id']).to eq 'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Fv2%2Ffile%2Fzb733jx3137%2Fversion%2F2%2Ftest_file_v1.pdf'
      expect(probe_service['service']).to include hash_including 'type' => 'AuthAccessService2'
      expect(probe_service.dig('service', 0, 'service')).to include hash_including 'type' => 'AuthAccessTokenService2'
    end
  end

  context 'when purl does not exist (dark)' do
    it 'is not found' do
      get '/bc123df4567/iiif3/manifest'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when requesting a /iiif/ route (not /iiif3)' do
    context 'with a collection' do
      it 'renders a iiif v3 collection manifest' do
        get '/sk882gx0113/iiif/manifest'

        expect(json['@context']).to include('http://iiif.io/api/presentation/3/context.json')
        expect(json['type']).to eq 'Collection'
      end
    end

    context 'with a file object' do
      it 'renders a iiif v3 manifest' do
        get '/gx074xz5520/iiif/manifest'

        expect(json['@context']).to include('http://iiif.io/api/presentation/3/context.json')
        expect(json['id']).to eq 'http://www.example.com/gx074xz5520/iiif/manifest'
        expect(json['label']['en']).to eq ['Minutes, 2006 May 18']
      end
    end
  end

  context 'when viewing direction is defined' do
    it 'includes viewing direction' do
      get '/yr183sf1341/iiif3/manifest'
      expect(json['viewingDirection']).to eq 'right-to-left'
    end
  end

  context 'when viewing direction is not defined' do
    it 'uses left-to-right as default viewing direction' do
      get '/rp193xx6845/iiif3/manifest'
      expect(json['viewingDirection']).to eq('left-to-right')
    end
  end

  context 'with a Stanford-only image' do
    it 'includes authorization services' do
      get '/bb001dq8600/iiif3/manifest'
      expect(json['items'].length).to eq 1
      canvas = json['items'].first
      expect(canvas['items'].first['items'].length).to eq 1
      image = canvas['items'].first['items'].first
      service = image['body']['service'].first
      expect(service['services']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/login'

      login_service = service['services'].detect { |x| x['profile'] == 'http://iiif.io/api/auth/1/login' }
      expect(login_service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/token'
      expect(login_service['label']).to eq 'Log in to access all available features.'
      expect(login_service['confirmLabel']).to eq 'Login'
      expect(login_service['failureHeader']).to eq 'Unable to authenticate'
      expect(login_service['failureDescription']).to eq 'The authentication serv' \
                                                        'ice cannot be reached. If your browser is configured to block pop-up wi' \
                                                        'ndows, try allowing pop-up windows for this site before attempting to l' \
                                                        'og in again.'
    end
  end

  it 'properly decodes XML entities into their UTF-8 characters' do
    get '/bb737zp0787/iiif3/manifest'
    expect(json['requiredStatement']['value']['en'].first)
      .to eq 'Property rights reside with the repository. Copyright © Stanford University. All Rights Reserved.'
  end

  it 'publishes IIIF manifests for books with image constituents and pdf in rendering' do
    get '/zf119tw4418/iiif3/manifest'

    expect(json['rendering'].length).to eq 1
    expect(json['rendering'].first['id']).to eq 'https://stacks.stanford.edu/file/zf119tw4418/zf119tw4418_31_0000.pdf'

    canvas = json['items'].first
    expect(canvas['items'].length).to eq 1
    expect(canvas['items'].first['items'].length).to eq 1
    expect(canvas['label']['en'].first).to eq 'Image 1'
    expect(canvas['rendering'].length).to eq 2
    expect(canvas['rendering'].first['label']['en']).to eq ['Original source file (1.1 MB)']
    expect(canvas['rendering'].first['id']).to end_with '/file/zf119tw4418/zf119tw4418_00_0001.jp2'
    expect(canvas['rendering'].last['label']['en']).to eq ['zf119tw4418_06_0001.pdf']
    expect(canvas['rendering'].last['id']).to end_with '/file/zf119tw4418/zf119tw4418_06_0001.pdf'

    image = canvas['items'].first['items'].first
    expect(image['body']['id']).to end_with '/image/iiif/zf119tw4418%2Fzf119tw4418_00_0001/full/full/0/default.jpg'
    expect(image['body']['height']).to eq 2959
    expect(image['body']['width']).to eq 2058

    expect(json['items'].length).to eq 57
    expect(json['metadata'].size).to eq 13
    expect(json['metadata'].flat_map do |elem|
      elem['label']['en']
    end).to eq ['Available Online', 'Title', 'Type', 'Language', 'Statement of responsibility', 'Date/sequential designation', 'Description',
                'Additional physical form', 'System details', 'Subject', 'Date', 'Identifier', 'PublishDate']
  end

  context 'when pages do not have OCR content' do
    it 'does not publish search services' do
      get '/rp193xx6845/iiif3/manifest'

      expect(json).not_to have_key 'service'
    end
  end

  context 'when pages have OCR content' do
    it 'publishes IIIF Content Search API' do
      get '/bb737zp0787/iiif3/manifest'

      expect(json['service'].first).to match '@context' => 'http://iiif.io/api/search/1/context.json',
                                             '@id' => 'http://example.com/content_search/bb737zp0787/search',
                                             'profile' => 'http://iiif.io/api/search/1/search',
                                             'label' => 'Search within this manifest'
    end
  end

  # Virtual objects consist of a parent object and children objects who hold the file resources
  context 'with virtual objects' do
    describe 'first child object' do
      let(:druid) { 'cg767mn6478' }

      it 'generates a correct manifest' do
        get "/#{druid}/iiif3/manifest"
        expect(response).to have_http_status(:ok)

        expect(json['label']['en'].first).to start_with '(Covers to) Carey\'s American Atlas'
        expect(json['items'].length).to eq 1

        canvas = json['items'].first
        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['label']['en'].first).to eq 'Image 1'

        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/full/0/default.jpg'
        expect(image['body']['height']).to eq 4747
        expect(image['body']['width']).to eq 6475
      end
    end

    describe 'second child object' do
      let(:druid) { 'jw923xn5254' }

      it 'generates a correct manifest' do
        get "/#{druid}/iiif3/manifest"
        expect(response).to have_http_status(:ok)

        expect(json['label']['en'].first).to start_with '(Title Page to) Carey\'s American Atlas'
        expect(json['items'].length).to eq 1

        canvas = json['items'].first
        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['label']['en'].first).to eq 'Image 1'

        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/jw923xn5254%2F2542B/full/full/0/default.jpg'
        expect(image['body']['height']).to eq 4675
        expect(image['body']['width']).to eq 3139
      end
    end

    describe 'parent object' do
      let(:druid) { 'hj097bm8879' }

      it 'generates a correct manifest' do
        get "/#{druid}/iiif3/manifest"
        expect(response).to have_http_status(:ok)

        expect(json['label']['en'].first).to start_with 'Carey\'s American Atlas'
        expect(json['thumbnail']).to be_an Array
        expect(json['thumbnail'].size).to eq 1
        expect(json['thumbnail'].first['id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/!400,400/0/default.jpg' # first child
        expect(json['items'].length).to eq 23

        canvas = json['items'].first
        expect(canvas['label']['en'].first).to start_with "(Covers to) Carey's American Atlas:"

        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/full/0/default.jpg' # first child
        expect(image['body']['height']).to eq 4747
        expect(image['body']['width']).to eq 6475

        canvas = json['items'].second
        expect(canvas['label']['en'].first).to start_with "(Title Page to) Carey's American Atlas:"

        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/jw923xn5254%2F2542B/full/full/0/default.jpg' # second child
        expect(image['body']['height']).to eq 4675
        expect(image['body']['width']).to eq 3139
      end
    end
  end

  context 'with a file object with world access' do
    let(:druid) { 'wm135gp2721' }

    it 'generates a correct manifest' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)

      expect(json['label']['en'].first).to eq 'A Newly Digitised Ice-penetrating Radar Dataset Acquired over the Greenland Ice Sheet in 1971-1979'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first

      expect(canvas['id']).to eq 'http://www.example.com/wm135gp2721/iiif3/canvas/cocina-fileSet-wm135gp2721-27313eb4-fb71-423d-9a82-05964f68d39f'
      expect(canvas['label']['en']).to eq ['image']
      expect(canvas['type']).to eq 'Canvas'
    end
  end

  context 'with a Stanford-only file object' do
    let(:druid) { 'bb253gh8060' }

    it 'generates a manifest with probe service' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)

      expect(json['label']['en'].first).to eq 'Agenda'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first

      expect(canvas['id']).to eq 'http://www.example.com/bb253gh8060/iiif3/canvas/cocina-fileSet-bb253gh8060-bb253gh8060_1'
      expect(canvas['label']['en']).to eq ['File 1']
      expect(canvas['type']).to eq 'Canvas'

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

  context 'with stanford only PDF' do
    let(:druid) { 'bh502xm3351' }

    it 'generates a manifest that includes the login service for the restricted file' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)

      expect(json['label']['en'].first).to eq 'Catgut Acoustical Society newsletter. Number 20, 1973-11-01'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      expect(canvas['height']).not_to be_present
      expect(canvas['width']).not_to be_present

      pdf = canvas['items'].first['items'].first
      body = pdf.fetch('body')
      expect(body['id']).to eq 'https://stacks.stanford.edu/file/bh502xm3351/CAS_bh502xm3351.pdf'
      expect(body['format']).to eq 'application/pdf'
      expect(body['type']).to eq 'Text'

      probe_service = body.fetch('service').first
      expect(probe_service['type']).to eq 'AuthProbeService2'
      expect(probe_service['id']).to eq 'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Ffile%2Fbh502xm3351%2FCAS_bh502xm3351.pdf'
      expect(probe_service['service']).to include hash_including 'type' => 'AuthAccessService2'
      expect(probe_service.dig('service', 0, 'service')).to include hash_including 'type' => 'AuthAccessTokenService2'
    end
  end

  context 'with a 3D object' do
    let(:druid) { 'bg387kw8222' }

    it 'generates a correct IIIF v3 manifest' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)

      expect(json['label']['en'].first).to start_with 'Department of Anthropology Bone Collection'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      expect(canvas['height']).not_to be_present
      expect(canvas['width']).not_to be_present

      obj = canvas['items'].first['items'].first
      expect(obj['body']['id']).to eq 'https://stacks.stanford.edu/file/bg387kw8222/bg387kw8222_low.glb'
      expect(obj['body']['format']).to eq 'model/gltf-binary'
      expect(obj['body']['type']).to eq 'Dataset'
    end
  end

  context 'when the object has no published files' do
    let(:druid) { 'bg387kw8222' }
    let(:resource) { instance_double(PurlResource, version:) }
    let(:version) { instance_double(PurlVersion, type: 'image', updated_at: 2.days.ago, cache_key: 'resource/xxx', ready?: true) }

    before do
      allow(PurlResource).to receive(:find).and_return(resource)
      allow(version).to receive(:iiif3_manifest).and_raise(IIIF::V3::Presentation::MissingRequiredKeyError)
    end

    it 'returns 404' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'with a geo object' do
    let(:druid) { 'cg357zz0321' }

    it 'only generates metadata' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)
      expect(json['label']['en'].first).to eq '10 Meter Contours: Russian River Basin, California'
      expect(json['metadata'].size).to eq 15
      expect(json['metadata'].flat_map do |elem|
        elem['label']['en']
      end).to eq ['Available Online', 'Title', 'Type', 'Format', 'Language', 'Abstract', 'Purpose', 'Preferred citation',
                  'Supplemental information', 'WGS84 Cartographics', 'Subject', 'Coverage', 'Date', 'Identifier', 'PublishDate']
    end
  end

  context 'with a 3D object as obj' do
    let(:druid) { 'bg387kw8222' }

    it 'only generates a single 3d resource on the canvas' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)

      expect(json['label']['en'].first).to start_with 'Department of Anthropology Bone Collection'
      expect(json['items'].length).to eq 1

      canvas = json['items'].first
      expect(canvas['items'].length).to eq 1
      expect(canvas['items'].first['items'].length).to eq 1
      expect(canvas['height']).not_to be_present
      expect(canvas['width']).not_to be_present

      obj = canvas['items'].first['items'].first
      expect(obj['body']['id']).to eq 'https://stacks.stanford.edu/file/bg387kw8222/bg387kw8222_low.glb'
      expect(obj['body']['format']).to eq 'model/gltf-binary'
      expect(obj['body']['type']).to eq 'Dataset'
    end
  end

  context 'with a location restricted image' do
    it 'generates a IIIF v3 manifest that includes location authentication information' do
      get '/tb420df0840/iiif3/manifest'
      expect(response).to have_http_status(:ok)

      external_interaction_service = json['items'].first['items'].first['items'].first['body']['service'].first['services'].first
      expect(external_interaction_service['profile']).to eq 'http://iiif.io/api/auth/1/external'
      expect(external_interaction_service['label']).to eq 'External Authentication Required'
      expect(external_interaction_service['failureHeader']).to eq 'Restricted Material'
      expect(external_interaction_service['failureDescription']).to eq 'Restricted content cannot be accessed from your location'
      expect(external_interaction_service['service'].first['@id']).to eq "#{Settings.stacks.url}/image/iiif/token"
      expect(external_interaction_service['service'].first['profile']).to eq 'http://iiif.io/api/auth/1/token'
    end
  end

  context 'with a location restricted media' do
    it 'generates a IIIF v3 manifest that includes location authentication information' do
      get '/yy816tv6021/iiif3/manifest'
      expect(response).to have_http_status(:ok)

      external_interaction_service = json['items'].first['items'].first['items'].first['body']['service'].first['service'].first
      expect(external_interaction_service['profile']).to eq 'active'
      expect(external_interaction_service['label']['en'].first).to eq 'Restricted content cannot be accessed from your location'
      expect(external_interaction_service['service'].first['id']).to eq "#{Settings.stacks.url}/iiif/auth/v2/token"
      expect(external_interaction_service['service'].first['type']).to eq 'AuthAccessTokenService2'
    end
  end

  context 'with a video object with captions' do
    let(:druid) { 'bd699ky6829' }

    it 'includes a placeholder canvas and caption annotations' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)

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

  context 'with an object that has coordinates' do
    let(:druid) { 'rp193xx6845' }

    it 'generates a correct manifest with navPlace' do
      get "/#{druid}/iiif3/manifest"
      expect(response).to have_http_status(:ok)

      expect(json['@context']).to include 'http://iiif.io/api/extension/navplace/context.json'
      features = json['navPlace']['features']
      expect(features.length).to eq 1
      expect(features[0]['geometry'].with_indifferent_access).to match({
                                                                         type: 'Polygon',
                                                                         coordinates: [
                                                                           [
                                                                             ['-23.9', '71.316666'],
                                                                             ['53.6', '71.316666'],
                                                                             ['53.6', '33.5'],
                                                                             ['-23.9', '33.5'],
                                                                             ['-23.9', '71.316666']
                                                                           ]
                                                                         ]
                                                                       })
    end
  end
end
