case Rails.configuration.upload_server
when :s3
  require "shrine/storage/s3"

  s3_options = {
    bucket:            ENV['UPLOADS_BUCKET'],
    region:            ENV['AWS_REGION'],
    access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  }

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "shrine/cache", **s3_options),
    store: Shrine::Storage::S3.new(prefix: "shrine/store", public: true, **s3_options),
  }
when :app
  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"),
  }
end

Shrine.plugin :upload_options, store: {cache_control: "public, max-age=31536000"}
Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :remove_attachment
Shrine.plugin :delete_raw
Shrine.plugin :determine_mime_type, analyzer: :marcel, log_subscriber: nil

Shrine.plugin :instrumentation if Rails.env.development? || Rails.env.staging?

case Rails.configuration.upload_server
when :s3
  Shrine.plugin :presign_endpoint, presign_options: -> (request) {
    {
      content_disposition: ContentDisposition.inline(request.params["filename"]),
      content_type: request.params["type"],
      content_length_range: 0..10.megabytes,
    }
  }
when :app
  Shrine.plugin :upload_endpoint
end
