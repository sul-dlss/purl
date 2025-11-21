# frozen_string_literal: true

class ResourceRetriever
  class ResourceNotFound < StandardError; end

  def initialize(druid:)
    @druid = druid
  end

  def meta_json_body
    @meta_json_body ||= open('meta.json')
  end

  def version_manifest_body
    @version_manifest_body ||= open('versions.json')
  end

  private

  attr_reader :druid

  def druid_tree
    Dor::Util.create_pair_tree(druid) || druid
  end

  def s3_key(filename)
    File.join(druid_tree, druid, 'versions', filename)
  end

  def open(filename)
    s3 = S3ClientFactory.create_client
    resp = s3.get_object(bucket: Settings.s3.bucket, key: s3_key(filename))
    resp.body.read
  rescue Aws::S3::Errors::NoSuchKey
    raise ResourceNotFound, "Resource not found: #{filename}"
  end
end
