require 'rails_helper'

describe 'IIIF manifests' do
  it 'works' do
    visit '/bb157hs6068/iiif/manifest.json'
    json = JSON.parse(page.body)

    expect(json['@context']).to eq 'http://iiif.io/api/presentation/2/context.json'
    expect(json['label']).to include 'NOUVELLE CARTE DE LA SPHERE POUR FAIRE CONNOITRE LES' # ...
    expect(json['description']).to eq 'Tom.1. No.9. (top right).'
    expect(json['attribution']).to eq 'Property rights reside with the repository. Copyright © Stanford University. All Rights Reserved.'
    expect(json['seeAlso']['@id']).to eq 'http://www.example.com/bb157hs6068.mods'
    expect(json['thumbnail']['@id']).to eq 'http://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/400,/0/default.jpg'

    expect(json['sequences'].length).to eq 1
    canvas = json['sequences'].first['canvases'].first

    expect(canvas['height']).to eq 9040
    expect(canvas['width']).to eq 10_481

    expect(canvas['images'].length).to eq 1
    image = canvas['images'].first

    expect(image['resource']['height']).to eq 9040
    expect(image['resource']['width']).to eq 10_481
    expect(image['resource']['@id']).to eq 'http://stacks-test.stanford.edu/image/iiif/bb157hs6068%2Fbb157hs6068_05_0001/full/full/0/default.jpg'
  end
end
