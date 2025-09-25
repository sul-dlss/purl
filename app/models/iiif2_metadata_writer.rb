# frozen_string_literal: true

class Iiif2MetadataWriter < Iiif3MetadataWriter
  def iiif_key_value(label, values)
    values.map do |value|
      { 'label' => label, 'value' => value }
    end
  end
end
