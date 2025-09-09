# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Iiif3PresentationManifest do
  subject(:manifest) { described_class.new(resource, controller:) }

  let(:resource) { PurlVersion.new }
  let(:controller) { PurlController.new }

  describe '#body' do
    subject(:json) { manifest.body.to_ordered_hash }

    let(:resource) { PurlResource.find(druid).version(:head) }
    let(:request) { ActionDispatch::TestRequest.create }

    before do
      allow(controller).to receive(:request).and_return(request)
    end

    context 'with a map with world access' do
      let(:druid) { 'bb157hs6068' }

      it 'has correct data' do
        expect(json['@context']).to include 'http://www.w3.org/ns/anno.jsonld', 'http://iiif.io/api/presentation/3/context.json'
        expect(json['label']['en'].first).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
        expect(json['summary']['en'].first).to eq 'Tom.1. No.9. (top right).'
        expect(json['requiredStatement']['value']['en'].first).to start_with 'This work has been identified as being free of known restrictions'
        expect(json['seeAlso'].first['id']).to eq 'http://test.host/bb157hs6068.mods'
        expect(json['thumbnail']).to be_an Array
        expect(json['thumbnail'].size).to eq 1
        expect(json['thumbnail'].first['id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'
        expect(json['thumbnail'].first['type']).to eq 'Image'
        expect(json['thumbnail'].first['width']).to eq 400
        expect(json['thumbnail'].first['height']).to eq 345

        expect(json['items'].length).to eq 1
        canvas = json['items'].first

        expect(canvas['height']).to eq 9040
        expect(canvas['width']).to eq 10_481

        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        image = canvas['items'].first['items'].first
        expect(image['body']['height']).to eq 9040
        expect(image['body']['width']).to eq 10_481
        expect(image['body']['id']).to eq 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/full/0/default.jpg'
      end
    end

    context 'with a book that has location specific access, no download files' do
      let(:druid) { 'rx923hn2102' }

      it 'does not include renderings, includes login service' do
        expect(json['renderings']).to be_nil
        canvas = json['items'].first
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['rendering']).to be_nil

        image = canvas['items'].first['items'].first
        service = image['body']['service'].first
        expect(service['services']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/external'

        login_service = service['services'].detect { |x| x['profile'] == 'http://iiif.io/api/auth/1/external' }
        expect(login_service['service']).to include hash_including 'profile' => 'http://iiif.io/api/auth/1/token'
        expect(login_service['label']).to eq 'External Authentication Required'
        expect(login_service['failureHeader']).to eq 'Restricted Material'
        expect(login_service['failureDescription']).to eq 'Restricted content cannot be accessed from your location'
      end
    end

    context 'with a Stanford-only image' do
      let(:druid) { 'bb001dq8600' }

      it 'includes authorization services' do
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

    context 'with a book that has image constituents and pdf in rendering' do
      let(:druid) { 'zf119tw4418' }

      it 'publishes IIIF manifests for' do
        expect(json['rendering'].length).to eq 1
        expect(json['rendering'].first['id']).to eq 'https://stacks.stanford.edu/file/zf119tw4418/zf119tw4418_31_0000.pdf'

        canvas = json['items'].first
        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['label']['en'].first).to eq 'Image 1'
        expect(canvas['rendering'].length).to eq 3
        expect(canvas['rendering'].first['label']['en']).to eq ['Original source file (1.1 MB)']
        expect(canvas['rendering'].first['id']).to end_with '/file/zf119tw4418/zf119tw4418_00_0001.jp2'
        expect(canvas['rendering'].last['label']['en']).to eq ['zf119tw4418_06_0001.pdf']
        expect(canvas['rendering'].last['id']).to end_with '/file/zf119tw4418/zf119tw4418_06_0001.pdf'

        image = canvas['items'].first['items'].first
        expect(image['body']['id']).to end_with '/image/iiif/zf119tw4418%2Fzf119tw4418_00_0001/full/full/0/default.jpg'
        expect(image['body']['height']).to eq 2959
        expect(image['body']['width']).to eq 2058

        expect(json['items'].length).to eq 57
        expect(json['metadata'].size).to eq 15
        expect(json['metadata'].flat_map do |elem|
          elem['label']['en']
        end).to eq ['Available Online', 'Title', 'Contributor', 'Type', 'Language', 'Statement of responsibility', 'Date/sequential designation', 'Description',
                    'Additional physical form', 'System details', 'Subject', 'Date', 'Identifier', 'Publisher', 'PublishDate']
      end
    end

    context 'when viewing direction is defined' do
      let(:druid) { 'yr183sf1341' }

      it 'includes viewing direction' do
        expect(json['viewingDirection']).to eq 'right-to-left'
      end
    end

    context 'when viewing direction is not defined' do
      let(:druid) { 'rp193xx6845' }

      it 'uses left-to-right as default viewing direction' do
        expect(json['viewingDirection']).to eq('left-to-right')
      end
    end

    context 'when pages do not have OCR content' do
      let(:druid) { 'rp193xx6845' }

      it 'does not publish search services' do
        expect(json).not_to have_key 'service'
      end
    end

    context 'when pages have OCR content' do
      let(:druid) { 'bb737zp0787' }

      it 'publishes IIIF Content Search API' do
        expect(json['service'].first).to match '@context' => 'http://iiif.io/api/search/1/context.json',
                                               '@id' => 'http://example.com/content_search/bb737zp0787/search',
                                               'profile' => 'http://iiif.io/api/search/1/search',
                                               'label' => 'Search within this manifest'
      end
    end

    # Virtual objects point at a list of other objects that contain files
    context 'with a virtual object' do
      let(:druid) { 'hj097bm8879' }

      it 'generates a correct manifest' do
        expect(json['label']['en'].first).to start_with 'Carey\'s American Atlas'
        expect(json['thumbnail']).to be_an Array
        expect(json['thumbnail'].size).to eq 1
        expect(json['thumbnail'].first['id']).to end_with '/image/iiif/cg767mn6478%2F2542A/full/!400,400/0/default.jpg' # first child
        expect(json['items'].length).to eq 2 # We only have two of the child items (cg767mn6478 & jw923xn5254) in the test data

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

    context 'with a file object' do
      context 'with world access' do
        let(:druid) { 'wm135gp2721' }

        it 'generates a correct manifest' do
          expect(json['label']['en'].first).to eq 'A Newly Digitised Ice-penetrating Radar Dataset Acquired over the Greenland Ice Sheet in 1971-1979'
          expect(json['items'].length).to eq 1

          canvas = json['items'].first

          expect(canvas['id']).to eq 'http://test.host/wm135gp2721/iiif/canvas/cocina-fileSet-wm135gp2721-27313eb4-fb71-423d-9a82-05964f68d39f'
          expect(canvas['label']['en']).to eq ['image']
          expect(canvas['type']).to eq 'Canvas'
        end
      end

      context 'with a Stanford-only access' do
        let(:druid) { 'bb253gh8060' }

        it 'generates a manifest with probe service' do
          expect(json['label']['en'].first).to eq 'Agenda'
          expect(json['items'].length).to eq 1

          canvas = json['items'].first

          expect(canvas['id']).to eq 'http://test.host/bb253gh8060/iiif/canvas/cocina-fileSet-bb253gh8060-bb253gh8060_1'
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
    end

    context 'with stanford only PDF' do
      let(:druid) { 'xq467yj8428' }

      it 'generates a manifest that includes the login service for the restricted file' do
        expect(json['label']['en'].first).to eq 'Marine Life Observatory Photoquadrats - READ ME File'
        expect(json['items'].length).to eq 1

        canvas = json['items'].first
        expect(canvas['items'].length).to eq 1
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['height']).not_to be_present
        expect(canvas['width']).not_to be_present

        pdf = canvas['items'].first['items'].first
        body = pdf.fetch('body')
        expect(body['id']).to eq 'https://stacks.stanford.edu/file/xq467yj8428/READ%20ME_MLOPhotoQuads.pdf'
        expect(body['format']).to eq 'application/pdf'
        expect(body['type']).to eq 'Text'

        probe_service = body.fetch('service').first
        expect(probe_service['type']).to eq 'AuthProbeService2'
        expect(probe_service['id']).to eq 'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Ffile%2Fxq467yj8428%2FREAD%2520ME_MLOPhotoQuads.pdf'
        expect(probe_service['service']).to include hash_including 'type' => 'AuthAccessService2'
        expect(probe_service.dig('service', 0, 'service')).to include hash_including 'type' => 'AuthAccessTokenService2'
      end
    end

    context 'with a geo object' do
      let(:druid) { 'cg357zz0321' }

      it 'only generates metadata' do
        expect(json['label']['en'].first).to eq '10 Meter Contours: Russian River Basin, California'
        expect(json['metadata'].size).to eq 18
        expect(json['metadata'].flat_map do |elem|
          elem['label']['en']
        end).to eq ['Available Online', 'Title', 'Creator', 'Contributor', 'Type', 'Format', 'Language', 'Abstract', 'Purpose', 'Preferred citation',
                    'Supplemental information', 'WGS84 Cartographics', 'Subject', 'Coverage', 'Date', 'Identifier', 'Publisher', 'PublishDate']
      end
    end

    context 'with a 3D object' do
      let(:druid) { 'bg387kw8222' }

      it 'only generates a single 3d resource on the canvas' do
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
      let(:druid) { 'tb420df0840' }

      it 'generates a IIIF v3 manifest that includes location authentication information' do
        external_interaction_service = json['items'].first['items'].first['items'].first['body']['service'].first['services'].first
        expect(external_interaction_service['profile']).to eq 'http://iiif.io/api/auth/1/external'
        expect(external_interaction_service['label']).to eq 'External Authentication Required'
        expect(external_interaction_service['failureHeader']).to eq 'Restricted Material'
        expect(external_interaction_service['failureDescription']).to eq 'Restricted content cannot be accessed from your location'
        expect(external_interaction_service['service'].first['@id']).to eq "#{Settings.stacks.url}/image/iiif/token"
        expect(external_interaction_service['service'].first['profile']).to eq 'http://iiif.io/api/auth/1/token'
      end
    end

    context 'with a media object' do
      context 'with location restrictions' do
        let(:druid) { 'yy816tv6021' }

        it 'generates a IIIF v3 manifest that includes location authentication information' do
          external_interaction_service = json['items'].first['items'].first['items'].first['body']['service'].first['service'].first
          expect(external_interaction_service['profile']).to eq 'active'
          expect(external_interaction_service['label']['en'].first).to eq 'Restricted content cannot be accessed from your location'
          expect(external_interaction_service['service'].first['id']).to eq "#{Settings.stacks.url}/iiif/auth/v2/token"
          expect(external_interaction_service['service'].first['type']).to eq 'AuthAccessTokenService2'
        end
      end

      context 'with captions' do
        let(:druid) { 'bd699ky6829' }

        it 'includes a placeholder canvas and caption annotations' do
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

      context 'with a fileset that has no primary file (has a disk image)' do
        let(:druid) { 'fj935vg7746' }

        it "skips making a canvas when we can't display the file" do
          expect(json['label']['en'].first).to eq 'شيرين'
          expect(json['items'].length).to eq 2

          canvas = json['items'].first

          expect(canvas['id']).to eq 'http://test.host/fj935vg7746/iiif/canvas/cocina-fileSet-fj935vg7746-fj935vg7746_2'
          expect(canvas['label']['en']).to eq ['filelist']
          expect(canvas['type']).to eq 'Canvas'
        end
      end
    end

    context 'with a map that has coordinates' do
      let(:druid) { 'rp193xx6845' }

      it 'generates a correct manifest with navPlace' do
        expect(json['@context']).to include 'http://iiif.io/api/extension/navplace/context.json'
        features = json['navPlace'][:features]
        expect(features.length).to eq 1
        expect(features[0][:geometry]).to match({
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
end
