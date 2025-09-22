# frozen_string_literal: true

task update_metadata: :environment do
  Settings.landing_page_druids.each do |druid|
    FixtureLoader.load(druid)
  end
end
