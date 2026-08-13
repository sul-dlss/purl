# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/sitemap_kafka_reader'

RSpec.describe SitemapKafkaReader do
  subject(:reader) { described_class.new(hosts: 'kafka.example.com:9092', topic: 'sitemap_release_prod', consumer:) }

  let(:consumer) { instance_double(Rdkafka::Consumer, close: nil) }
  let(:released) do
    message(
      offset: 0,
      key: 'druid:bb000qr5025',
      value: { druid: 'druid:bb000qr5025', true_targets: ['PURL sitemap'], updated_at: '2026-08-12T12:00:00Z' }.to_json
    )
  end
  let(:unreleased) do
    message(
      offset: 1,
      key: 'druid:bb000qr5025',
      value: { druid: 'druid:bb000qr5025', false_targets: ['PURL sitemap'], updated_at: '2026-08-13T12:00:00Z' }.to_json
    )
  end
  let(:currently_released) do
    message(
      offset: 2,
      key: 'druid:bc854fy5899',
      value: { druid: 'druid:bc854fy5899', true_targets: ['PURL sitemap'], updated_at: '2026-08-13T12:00:00Z' }.to_json
    )
  end
  let(:deleted_release) do
    message(
      offset: 0,
      key: 'druid:bd786fy6312',
      value: { druid: 'druid:bd786fy6312', true_targets: ['PURL sitemap'], updated_at: '2026-08-12T12:00:00Z' }.to_json
    )
  end
  let(:deleted) { message(offset: 1, key: 'druid:bd786fy6312', value: nil) }

  before do
    metadata = instance_double(
      Rdkafka::Metadata,
      topics: [{ topic_name: 'sitemap_release_prod', partitions: [{ partition_id: 0 }, { partition_id: 1 }] }]
    )
    allow(consumer).to receive(:metadata).with('sitemap_release_prod').and_return(metadata)
    allow(consumer).to receive(:query_watermark_offsets).with('sitemap_release_prod', 0).and_return([0, 3])
    allow(consumer).to receive(:query_watermark_offsets).with('sitemap_release_prod', 1).and_return([0, 2])
    allow(consumer).to receive(:assign)
    allow(consumer).to receive(:poll).with(1_000).and_return(released, unreleased, currently_released, deleted_release, deleted)
  end

  it 'returns only PURLs whose latest message is released to the sitemap' do
    expect(reader.to_a).to eq([JSON.parse(currently_released.payload)])
    expect(consumer).to have_received(:close)
  end

  it 'returns an enumerator when no block is provided' do
    expect(reader.each).to be_an(Enumerator)
  end

  def message(offset:, key:, value:)
    instance_double(Rdkafka::Consumer::Message, offset:, key:, payload: value)
  end
end
