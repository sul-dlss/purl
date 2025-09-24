# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Iiif3PresentationManifest do
  subject(:manifest) { described_class.new(resource, controller:, iiif_namespace:) }

  let(:resource) { PurlVersion.new }
  let(:controller) { PurlController.new }
  let(:iiif_namespace) { :iiif }

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
        expect(json['seeAlso'].first['id']).to eq 'http://purl.stanford.edu/bb157hs6068.mods'
        expect(json['thumbnail']).to eq [
          { 'type' => 'Image',
            'id' => 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg',
            'format' => 'image/jpeg',
            'service' =>
           [{ 'id' => 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001',
              'type' => 'ImageService2',
              'profile' => 'http://iiif.io/api/image/2/level2.json' }],
            'width' => 400,
            'height' => 345 }
        ]

        expect(json['items'].length).to eq 1
        canvas = json['items'].first
        expect(canvas['height']).to eq 9040
        expect(canvas['width']).to eq 10_481

        expect(canvas['items']).to eq(
          [{ 'type' => 'AnnotationPage',
             'id' => 'http://purl.stanford.edu/bb157hs6068/iiif3/annotation_page/cocina-fileSet-bb157hs6068-bb157hs6068_1',
             'items' =>
             [{ 'type' => 'Annotation',
                'motivation' => 'painting',
                'id' => 'http://purl.stanford.edu/bb157hs6068/iiif/annotation/cocina-fileSet-bb157hs6068-bb157hs6068_1',
                'target' => 'https://purl.stanford.edu/bb157hs6068/iiif/canvas/cocina-fileSet-bb157hs6068-bb157hs6068_1',
                'body' =>
                { 'type' => 'Image',
                  'id' => 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/full/0/default.jpg',
                  'format' => 'image/jpeg',
                  'height' => 9040,
                  'width' => 10_481,
                  'service' =>
                  [{ 'id' => 'https://stacks.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001',
                     'type' => 'ImageService2',
                     'profile' => 'http://iiif.io/api/image/2/level2.json' }] } }] }]
        )
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

    context 'with a media item that has spaces' do
      let(:druid) { 'fs053dj6001' }

      it 'encodes the spaces in the urls' do
        canvas = json['items'].first
        expect(canvas['items'].first['items'].length).to eq 1
        expect(canvas['rendering']).to be_nil

        media = canvas['items'].first['items'].first
        expect(media['body']['id']).to eq 'https://stacks.stanford.edu/file/fs053dj6001/fs053dj6001_Concierge_77_Digital%20Accessibility_Nov2024_em_sl.mp4'
        expect(canvas['placeholderCanvas']['id']).to eq 'https://purl.stanford.edu/fs053dj6001/iiif/canvas/fs053dj6001_Concierge_77_Digital%20Accessibility_Nov2024_thumb.jp2'
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

    context 'with image that has annotations' do
      let(:druid) { 'hx163dc5225' }
      let(:iiif_namespace) { :iiif3 }

      it 'provides annotations for annotations' do
        expect(json.dig('items', 7, 'annotations')).to eq [
          {
            id: 'http://purl.stanford.edu/hx163dc5225/iiif3/annotations/cocina-fileSet-hx163dc5225-hx163dc5225_8',
            type: 'AnnotationPage'
          }
        ]
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
                    'Additional physical form', 'System details', 'Subject', 'Date', 'Identifier', 'Publisher', 'Record published']
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

      it 'generates a correct manifest' do # rubocop:disable RSpec/ExampleLength
        expect(json['label']['en'].first).to start_with 'Carey\'s American Atlas'
        expect(json['thumbnail']).to eq [
          { 'type' => 'Image',
            'id' => 'https://stacks.stanford.edu/image/iiif/cg767mn6478%2F2542A/full/!400,400/0/default.jpg', # first child
            'format' => 'image/jpeg',
            'service' =>
             [{ 'id' => 'https://stacks.stanford.edu/image/iiif/cg767mn6478%2F2542A',
                'type' => 'ImageService2',
                'profile' => 'http://iiif.io/api/image/2/level2.json' }],
            'width' => 400,
            'height' => 293 }
        ]

        expect(json['items'].length).to eq 2 # We only have two of the child items (cg767mn6478 & jw923xn5254) in the test data

        canvas = json['items'].first
        expect(canvas['label']['en'].first).to start_with "(Covers to) Carey's American Atlas:"
        expect(canvas['items']).to eq [
          { 'type' => 'AnnotationPage',
            'id' => 'http://purl.stanford.edu/hj097bm8879/iiif3/annotation_page/cocina-fileSet-cg767mn6478-cg767mn6478_1',
            'items' =>
           [{ 'type' => 'Annotation',
              'motivation' => 'painting',
              'id' => 'http://purl.stanford.edu/hj097bm8879/iiif/annotation/cocina-fileSet-cg767mn6478-cg767mn6478_1',
              'target' => 'https://purl.stanford.edu/hj097bm8879/iiif/canvas/cocina-fileSet-cg767mn6478-cg767mn6478_1',
              'body' =>
              { 'type' => 'Image',
                'id' => 'https://stacks.stanford.edu/image/iiif/cg767mn6478%2F2542A/full/full/0/default.jpg',
                'format' => 'image/jpeg',
                'height' => 4747,
                'width' => 6475,
                'service' =>
                [{ 'id' => 'https://stacks.stanford.edu/image/iiif/cg767mn6478%2F2542A',
                   'type' => 'ImageService2',
                   'profile' => 'http://iiif.io/api/image/2/level2.json' }] } }] }
        ]

        canvas = json['items'].second
        expect(canvas['label']['en'].first).to start_with "(Title Page to) Carey's American Atlas:"
        expect(canvas['items']).to eq [
          { 'type' => 'AnnotationPage',
            'id' => 'http://purl.stanford.edu/hj097bm8879/iiif3/annotation_page/cocina-fileSet-jw923xn5254-jw923xn5254_1',
            'items' =>
           [{ 'type' => 'Annotation',
              'motivation' => 'painting',
              'id' => 'http://purl.stanford.edu/hj097bm8879/iiif/annotation/cocina-fileSet-jw923xn5254-jw923xn5254_1',
              'target' => 'https://purl.stanford.edu/hj097bm8879/iiif/canvas/cocina-fileSet-jw923xn5254-jw923xn5254_1',
              'body' =>
              { 'type' => 'Image',
                'id' => 'https://stacks.stanford.edu/image/iiif/jw923xn5254%2F2542B/full/full/0/default.jpg', # second child
                'format' => 'image/jpeg',
                'height' => 4675,
                'width' => 3139,
                'service' =>
                [{ 'id' => 'https://stacks.stanford.edu/image/iiif/jw923xn5254%2F2542B',
                   'type' => 'ImageService2',
                   'profile' => 'http://iiif.io/api/image/2/level2.json' }] } }] }
        ]
      end
    end

    context 'with a file object' do
      context 'with world access' do
        let(:druid) { 'wm135gp2721' }

        it 'generates a correct manifest' do
          expect(json['label']['en'].first).to eq 'A Newly Digitised Ice-penetrating Radar Dataset Acquired over the Greenland Ice Sheet in 1971-1979'
          expect(json['items'].length).to eq 1

          canvas = json['items'].first

          expect(canvas['id']).to eq 'https://purl.stanford.edu/wm135gp2721/iiif/canvas/cocina-fileSet-wm135gp2721-27313eb4-fb71-423d-9a82-05964f68d39f'
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

          expect(canvas['id']).to eq 'https://purl.stanford.edu/bb253gh8060/iiif/canvas/cocina-fileSet-bb253gh8060-bb253gh8060_1'
          expect(canvas['label']['en']).to eq ['File 1']
          expect(canvas['type']).to eq 'Canvas'

          expect(canvas['height']).not_to be_present
          expect(canvas['width']).not_to be_present
          expect(canvas['items']).to eq(
            [{ 'type' => 'AnnotationPage',
               'id' => 'http://purl.stanford.edu/bb253gh8060/iiif3/annotation_page/cocina-fileSet-bb253gh8060-bb253gh8060_1',
               'items' =>
              [{ 'type' => 'Annotation',
                 'motivation' => 'painting',
                 'id' => 'http://purl.stanford.edu/bb253gh8060/iiif/annotation/cocina-fileSet-bb253gh8060-bb253gh8060_1',
                 'target' => 'https://purl.stanford.edu/bb253gh8060/iiif/canvas/cocina-fileSet-bb253gh8060-bb253gh8060_1',
                 'body' =>
                  { 'id' => 'https://stacks.stanford.edu/file/bb253gh8060/SC0193_Agenda_6381_2010-10-07_001.pdf',
                    'type' => 'Text',
                    'label' => { 'en' => ['SC0193_Agenda_6381_2010-10-07_001.pdf'] },
                    'format' => 'application/pdf',
                    'service' =>
                    [{ 'id' =>
                      'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Ffile%2Fbb253gh8060%2FSC0193_Agenda_6381_2010-10-07_001.pdf',
                       'type' => 'AuthProbeService2',
                       'errorHeading' => { 'en' => ['No access'] },
                       'errorNote' => { 'en' => ['You do not have permission to access this resource'] },
                       'service' =>
                      [{ 'id' => 'https://stacks.stanford.edu/auth/iiif',
                         'type' => 'AuthAccessService2',
                         'profile' => 'active',
                         'label' => { 'en' => ['Stanford users: log in to access all available features'] },
                         'confirmLabel' => { 'en' => ['Log in'] },
                         'service' =>
                          [{ 'id' => 'https://stacks.stanford.edu/iiif/auth/v2/token',
                             'type' => 'AuthAccessTokenService2',
                             'errorHeading' => { 'en' => ['Something went wrong'] },
                             'errorNote' => { 'en' => ['Could not get a token.'] } }] }] }] } }] }]
          )
        end
      end
    end

    context 'with stanford only PDF' do
      let(:druid) { 'xq467yj8428' }

      it 'generates a manifest that includes the login service for the restricted file' do
        expect(json['label']['en'].first).to eq 'Marine Life Observatory Photoquadrats - READ ME File'
        expect(json['items'].length).to eq 1

        canvas = json['items'].first
        expect(canvas['items']).to eq(
          [{ 'type' => 'AnnotationPage',
             'id' => 'http://purl.stanford.edu/xq467yj8428/iiif3/annotation_page/cocina-fileSet-xq467yj8428-xq467yj8428_1',
             'items' =>
             [{ 'type' => 'Annotation',
                'motivation' => 'painting',
                'id' => 'http://purl.stanford.edu/xq467yj8428/iiif/annotation/cocina-fileSet-xq467yj8428-xq467yj8428_1',
                'target' => 'https://purl.stanford.edu/xq467yj8428/iiif/canvas/cocina-fileSet-xq467yj8428-xq467yj8428_1',
                'body' =>
                { 'id' => 'https://stacks.stanford.edu/file/xq467yj8428/READ%20ME_MLOPhotoQuads.pdf',
                  'type' => 'Text',
                  'label' => { 'en' => ['READ ME_MLOPhotoQuads.pdf'] },
                  'format' => 'application/pdf',
                  'service' =>
                  [{ 'id' => 'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Ffile%2Fxq467yj8428%2FREAD%2520ME_MLOPhotoQuads.pdf',
                     'type' => 'AuthProbeService2',
                     'errorHeading' => { 'en' => ['No access'] },
                     'errorNote' => { 'en' => ['You do not have permission to access this resource'] },
                     'service' =>
                     [
                       { 'confirmLabel' => { 'en' => ['Log in'] },
                         'id' => 'https://stacks.stanford.edu/auth/iiif',
                         'label' =>
                             { 'en' =>
                             ['Stanford users: log in to access all available features'] },
                         'profile' => 'active',
                         'service' => [
                           { 'id' => 'https://stacks.stanford.edu/iiif/auth/v2/token',
                             'type' => 'AuthAccessTokenService2',
                             'errorHeading' => { 'en' => ['Something went wrong'] },
                             'errorNote' => { 'en' => ['Could not get a token.'] } }
                         ],
                         'type' => 'AuthAccessService2' }
                     ] }] } }] }]
        )
      end
    end

    context 'with a geo object' do
      let(:druid) { 'cg357zz0321' }

      it 'only generates metadata' do
        expect(json['label']['en'].first).to eq '10 Meter Contours: Russian River Basin, California'
        expect(json['metadata'].size).to eq 17
        expect(json['metadata'].flat_map do |elem|
          elem['label']['en']
        end).to eq ['Available Online', 'Title', 'Creator', 'Type', 'Format', 'Language', 'Abstract', 'Purpose', 'Preferred citation',
                    'Supplemental information', 'WGS84 Cartographics', 'Subject', 'Coverage', 'Date', 'Identifier', 'Publisher', 'Record published']
      end
    end

    context 'with a 3D object' do
      let(:druid) { 'bg387kw8222' }

      it 'only generates a single 3d resource on the canvas' do
        expect(json['label']['en'].first).to start_with 'Department of Anthropology Bone Collection'
        expect(json['items'].length).to eq 1

        canvas = json['items'].first
        expect(canvas['items']).to eq(
          [{ 'type' => 'AnnotationPage',
             'id' => 'http://purl.stanford.edu/bg387kw8222/iiif3/annotation_page/cocina-fileSet-bg387kw8222-bg387kw8222_7',
             'items' =>
           [{ 'type' => 'Annotation',
              'motivation' => 'painting',
              'id' => 'http://purl.stanford.edu/bg387kw8222/iiif/annotation/cocina-fileSet-bg387kw8222-bg387kw8222_7',
              'target' => 'https://purl.stanford.edu/bg387kw8222/iiif/canvas/cocina-fileSet-bg387kw8222-bg387kw8222_7',
              'body' =>
              { 'id' => 'https://stacks.stanford.edu/file/bg387kw8222/bg387kw8222_low.glb',
                'type' => 'Dataset',
                'label' => { 'en' => ['bg387kw8222_low.glb'] },
                'format' => 'model/gltf-binary',
                'service' =>
                [{ 'id' => 'https://stacks.stanford.edu/iiif/auth/v2/probe?id=https%3A%2F%2Fstacks.stanford.edu%2Ffile%2Fbg387kw8222%2Fbg387kw8222_low.glb',
                   'type' => 'AuthProbeService2',
                   'errorHeading' => { 'en' => ['No access'] },
                   'errorNote' => { 'en' => ['You do not have permission to access this resource'] },
                   'service' =>
                   [{ 'type' => 'AuthAccessService2',
                      'profile' => 'external',
                      'label' => { 'en' => ['Public users'] },
                      'service' =>
                      [{ 'id' => 'https://stacks.stanford.edu/iiif/auth/v2/token',
                         'type' => 'AuthAccessTokenService2',
                         'errorHeading' => { 'en' => ['Something went wrong'] },
                         'errorNote' => { 'en' => ['Could not get a token.'] } }] }] }] } }] }]
        )
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

          expect(canvas['id']).to eq 'https://purl.stanford.edu/fj935vg7746/iiif/canvas/cocina-fileSet-fj935vg7746-fj935vg7746_2'
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
