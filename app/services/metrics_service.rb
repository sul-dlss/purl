# frozen_string_literal: true

# Queries metrics from the SDR Metrics API
# https://github.com/sul-dlss/sdr-metrics-api
class MetricsService
  attr_reader :base_url

  def initialize(base_url: Settings.metrics_api_url)
    @base_url = base_url
  end

  def get_metrics(druid)
    get_json("/#{druid}/metrics")
  end

  private

  def get_json(url)
    response = connection.get(url)
    response.body.empty? ? nil : JSON.parse(response.body)
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error("Error querying metrics: #{e}")
    nil
  end

  def parse_json(response)
    response.body.empty? ? nil : JSON.parse(response.body)
  end

  def connection
    @connection ||= Faraday.new(base_url)
  end
end
