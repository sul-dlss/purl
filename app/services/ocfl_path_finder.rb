# frozen_string_literal: true

# Return paths to files stored in an OCFL file layout (https://ocfl.io/)
class OcflPathFinder
  def self.path(...)
    new(...).path
  end

  def initialize(druid_tree:, filename:)
    @druid_tree = druid_tree
    @filename = filename
  end

  def path
    return unless Settings.features.read_from_ocfl_root

    relative_path = directory.path(filepath: filename).relative_path_from(object_root)

    File.join(
      File.dirname(relative_path),
      File::SEPARATOR
    )
  rescue OCFL::Object::FileNotFound, Errno::ENOENT
    nil
  end

  private

  attr_reader :druid_tree, :filename

  def object_root
    File.join(Settings.ocfl_root, druid_tree)
  end

  def directory
    OCFL::Object::Directory.new(object_root:)
  end
end
