# frozen_string_literal: true

class AcceptHeaderConstraint
  PRESENTATION_V3_ACCEPT_HEADER = %r{application/ld\+json;profile="http://iiif.io/api/presentation/3/context\.json"}

  def matches?(request)
    PRESENTATION_V3_ACCEPT_HEADER.match?(request.headers['Accept'])
  end
end
