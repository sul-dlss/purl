# require 'dry-struct'

class Description
  MODS_NS = 'http://www.loc.gov/mods/v3'.freeze

  # Temporarily accepting nils to avoid fixing all tests.
  def initialize(mods_ng: nil, cocina_json: nil)
    @mods_ng = mods_ng
    @cocina_json = cocina_json
  end

  # Conventions:
  # * Prefer cocina naming.
  # * "formatted_" indicates that a complex structure has been reduced to a string.

  delegate :doi, :doi_id, to: :mods_identifier
  delegate :publication_year, to: :mods_origin_info
  delegate :formatted_title, to: :cocina_title
  delegate :descriptions, :formatted_description, to: :cocina_note
  delegate :contributors, to: :cocina_contributor

  def formatted_contributors
    # Temporary workaround to avoid fixing all tests.
    # Otherwise, would be: delegate :doi, to: :cocina_identifier
    cocina_json.present? ? cocina_contributor.formatted_contributors : mods_formatted_name.formatted_names
  end

  def doi
    # Temporary workaround to avoid fixing all tests.
    # Otherwise, would be: delegate :doi, to: :cocina_identifier
    cocina_json.present? ? cocina_identifier.doi : mods_identifier.doi
  end

  def doi_id
    # Temporary workaround to avoid fixing all tests.
    # Otherwise, would be: delegate :doi_id, to: :cocina_identifier
    cocina_json.present? ? cocina_identifier.doi_id : mods_identifier.doi_id
  end

  private

  attr_reader :mods_ng, :cocina_json

  def cocina_identifier
    @cocina_identifier ||= CocinaIdentifier.new(cocina_json:)
  end

  def mods_identifier
    @mods_identifier ||= ModsIdentifier.new(mods_ng:)
  end

  def mods_origin_info
    @mods_origin_info ||= ModsOriginInfo.new(mods_ng:)
  end

  def mods_formatted_name
    @mods_formatted_name ||= ModsFormattedName.new(mods_ng:)
  end

  def cocina_title
    @cocina_title ||= CocinaTitle.new(cocina_json:)
  end

  def cocina_note
    @cocina_note ||= CocinaNote.new(cocina_json:)
  end

  def cocina_contributor
    @cocina_contributor ||= CocinaContributor.new(cocina_json:)
  end

  module Types
    include Dry.Types()
  end

  # Base class for Structs
  class DescriptionStruct < Dry::Struct
    transform_keys(&:to_sym)
    schema schema.strict
  end

  class Contributor < DescriptionStruct
    attribute :name, Types::String
    attribute? :forename, Types::String
    attribute? :surname, Types::String
    attribute? :orcid, Types::String
  end
end
