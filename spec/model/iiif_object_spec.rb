# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifObject do
  subject(:iiif_object) { described_class.new(druid: 'bc123df4567', display_title: 'Test object') }

  it 'is an Active Model model' do
    expect(iiif_object).to be_a ActiveModel::Model
  end

  it 'assigns attributes' do
    expect(iiif_object).to have_attributes(druid: 'bc123df4567', display_title: 'Test object')
  end

  describe 'type predicates' do
    subject(:iiif_object) { described_class.new(item_type:) }

    let(:item_type) { instance_double(ItemType, collection?: true, book?: false) }

    it 'exposes collection and book predicates' do
      expect(iiif_object).to be_collection
      expect(iiif_object).not_to be_book
    end
  end
end
