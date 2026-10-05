# frozen_string_literal: true

require 'json'
require 'rdkafka'

class SitemapKafkaReader
  include Enumerable

  RELEASE_TARGET = 'PURL sitemap'
  def initialize(hosts:, topic:, consumer: nil)
    @consumer = consumer || build_consumer(hosts)
    @topic = topic
  end

  def each(&)
    return enum_for(:each) unless block_given?

    begin
      releases = {}
      each_message do |message|
        if message.payload.nil?
          releases.delete(message.key)
          next
        end

        purl = JSON.parse(message.payload)
        if purl.fetch('true_targets', []).include?(RELEASE_TARGET)
          releases[purl.fetch('druid')] = purl
        else
          releases.delete(purl.fetch('druid'))
        end
      end

      releases.each_value(&)
    ensure
      @consumer.close
    end
  end

  private

  def build_consumer(hosts)
    Rdkafka::Config.new(
      'bootstrap.servers': hosts,
      'group.id': 'purl-sitemap-generator',
      'enable.auto.commit': false,
      'enable.partition.eof': true
    ).consumer
  end

  def each_message(&)
    partition_ids.each do |partition|
      low_offset, high_offset = @consumer.query_watermark_offsets(@topic, partition)
      next if low_offset >= high_offset

      assign(partition, low_offset)
      poll_partition(high_offset, &)
    end
  end

  def partition_ids
    topic = @consumer.metadata(@topic).topics.find { |metadata| metadata.fetch(:topic_name) == @topic }
    topic.fetch(:partitions).map { |partition| partition.fetch(:partition_id) }
  end

  def assign(partition, offset)
    partitions = Rdkafka::Consumer::TopicPartitionList.new
    partitions.add_topic_and_partitions_with_offsets(@topic, partition => offset)
    @consumer.assign(partitions)
  end

  def poll_partition(high_offset)
    loop do
      message = @consumer.poll(1_000)
      next unless message
      break if message.offset >= high_offset

      yield message
      break if message.offset == high_offset - 1
    end
  rescue Rdkafka::RdkafkaError => e
    raise unless e.is_partition_eof?
  end
end
