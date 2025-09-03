# frozen_string_literal: true

# A lighter-weight version of PurlResource
class PreviewResource
  def initialize(mods)
    @mods = mods
  end

  attr_reader :mods

  def title
    Array.wrap(@mods.title).join(' -- ')
  end

  def containing_purl_collections
    []
  end

  def copyright?; end
  def use_and_reproduction?; end
  def catalog_key; end
  def type; end

  def respond_to_missing?(_name)
    true
  end

  def method_missing(method_name, *_args)
    Honeybadger.notify('Undefined method called on PreviewResource', context: { method_name: })
    nil
  end
end
