# frozen_string_literal: true

task update_metadata: :environment do
  Settings.landing_page_druids.each do |druid|
    tree = Dor::Util.create_pair_tree(druid)
    FileUtils.rm_f("#{Settings.stacks.root}/#{tree}")
    dest = "#{Settings.stacks.root}/#{tree}/#{druid}"
    src = "/stacks/#{tree}/#{druid}/versions"

    FileUtils.mkdir_p(dest)
    `scp -r lyberadmin@purl-fetcher-prod:#{src} #{dest}`
  end
end
