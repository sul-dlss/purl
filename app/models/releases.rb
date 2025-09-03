# frozen_string_literal: true

class Releases
  def initialize(meta_json)
    @meta_json = meta_json
  end

  attr_reader :meta_json

  # Can be crawled / indexed by a crawler, e.g. Googlebot
  def crawlable?
    meta_json.fetch('sitemap')
  end

  def released_to_searchworks?
    meta_json.fetch('searchworks')
  end

  def released_to_earthworks?
    meta_json.fetch('earthworks')
  end
end
