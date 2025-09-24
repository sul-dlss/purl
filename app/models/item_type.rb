# frozen_string_literal: true

class ItemType
  def initialize(type)
    @type = type
  end

  attr_reader :type

  def collection?
    type == 'https://cocina.sul.stanford.edu/models/collection'
  end

  def book?
    type == 'https://cocina.sul.stanford.edu/models/book'
  end

  def image?
    type == 'https://cocina.sul.stanford.edu/models/image'
  end

  def map?
    type == 'https://cocina.sul.stanford.edu/models/map'
  end

  def geo?
    type == 'https://cocina.sul.stanford.edu/models/geo'
  end

  def three_d?
    type == 'https://cocina.sul.stanford.edu/models/3d'
  end

  def webarchive_seed?
    type == 'https://cocina.sul.stanford.edu/models/webarchive-seed'
  end

  def webarchive_binary?
    type == 'https://cocina.sul.stanford.edu/models/webarchive-binary'
  end

  def object?
    type == 'https://cocina.sul.stanford.edu/models/object'
  end
end
