require "shrine/storage/s3"
require "shrine/storage/file_system"

if Rails.env.production? || Rails.env.staging?
  s3_options = {
    bucket:            ENV['UPLOADS_BUCKET'],
    region:            ENV['AWS_REGION'],
    access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  }

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "shrine/cache", **s3_options),
    store: Shrine::Storage::S3.new(prefix: "shrine/store", **s3_options),
  }
else
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("tmp", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("tmp", prefix: "uploads/store"),
  }
end

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :remove_attachment

