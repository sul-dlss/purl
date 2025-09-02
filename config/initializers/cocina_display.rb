Rails.application.config.to_prepare do
  CocinaDisplay.notifier = Honeybadger
end
