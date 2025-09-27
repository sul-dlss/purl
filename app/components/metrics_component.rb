# frozen_string_literal: true

class MetricsComponent < ViewComponent::Base
  def initialize(version:, metrics:)
    @version = version
    @metrics = metrics
    super()
  end

  attr_reader :version, :metrics

  delegate :embeddable?, :druid, :show_download_metrics?, :doi, to: :version

  def unique_views
    number_with_delimiter metrics['unique_views']
  end

  def unique_downloads
    number_with_delimiter metrics['unique_downloads']
  end

  def label_id
    'section-metrics'
  end
end
