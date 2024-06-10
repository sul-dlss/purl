# frozen_string_literal: true

# Return paths to files stored in an OCFL file layout (https://ocfl.io/)
class OcflPathFinder
  def self.path(...)
    new(...).path
  end

  def initialize(druid:, filename:)
    @druid = druid
    @filename = filename
  end

  def path
    return unless Settings.features.read_from_ocfl_root
    return 'extensions/sidecar-metadata/' if filename == 'meta.json'

    relative_path = ocfl_object.path(filepath: filename).relative_path_from(ocfl_object.root)

    File.join(
      File.dirname(relative_path),
      File::SEPARATOR
    )
  rescue OCFL::Object::FileNotFound, Errno::ENOENT
    nil
  end

  private

  attr_reader :druid, :filename

  def ocfl_object
    storage_root = OCFL::StorageRoot.new(base_directory: Settings.ocfl_root)
    storage_root.object(druid)
  end
end
