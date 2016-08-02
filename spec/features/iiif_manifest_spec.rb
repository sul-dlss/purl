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
    expect(json['thumbnail']['@id']).to eq 'https://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'

    expect(json['sequences'].length).to eq 1
    canvas = json['sequences'].first['canvases'].first

    expect(canvas['height']).to eq 9040
    expect(canvas['width']).to eq 10_481

    expect(canvas['images'].length).to eq 1
    image = canvas['images'].first

    expect(image['resource']['height']).to eq 9040
    expect(image['resource']['width']).to eq 10_481
    expect(image['resource']['@id']).to eq 'https://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/full/0/default.jpg'
  end

  it 'includes a representative thumbnail' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['thumbnail']['@id']).to eq 'https://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/!400,400/0/default.jpg'
    expect(json['thumbnail']['@type']).to eq 'dcterms:Image'
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
