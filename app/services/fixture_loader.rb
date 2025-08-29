# frozen_string_literal: true

class FixtureLoader
  def self.load(druid, machine: 'purl-fetcher-prod')
    # Load fixture data for the given druid
    tree = Dor::Util.create_pair_tree(druid)
    FileUtils.rm_f("spec/fixtures/document_cache/#{tree}")
    dest = "spec/fixtures/document_cache/#{tree}/#{druid}"
    src = "/stacks/#{tree}/#{druid}/versions"

    FileUtils.mkdir_p(dest)
    `scp -r lyberadmin@#{machine}:#{src} #{dest}`
  end
end
