# frozen_string_literal: true

class ItemType
  def initialize(type)
    @type = type
  end

  attr_reader :type

  def collection?
    type == 'collection'
  end

  def book?
    type == 'book'
  end

  def image?
    type == 'image'
  end

  def map?
    type == 'map'
  end

  def geo?
    type == 'geo'
  end

  def three_d?
    type == '3d'
  end

  def webarchive_seed?
    type == 'webarchive-seed'
  end

  def webarchive_binary?
    type == 'webarchive-binary'
  end

  def object?
    type == 'object'
  end

  def media?
    type == 'media'
  end
end
