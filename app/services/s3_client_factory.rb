# frozen_string_literal: true

# Creates an S3 client instance.
class S3ClientFactory
  def self.create_client
    Aws::S3::Client.new(
      region: 'us-east-1',
      endpoint: Settings.s3.endpoint,
      force_path_style: true, # Often required for custom endpoints
      access_key_id: Settings.s3.access_key_id,
      secret_access_key: Settings.s3.secret_access_key
    )
  end
end
