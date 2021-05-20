require "shrine/storage/s3"

s3_options = {
  bucket:            ENV['UPLOADS_BUCKET'],
  region:            ENV['AWS_REGION'],
  access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
}

Shrine.storages = {
  cache: Shrine::Storage::S3.new(prefix: "refile/cache", **s3_options),
  store: Shrine::Storage::S3.new(prefix: "refile/store", **s3_options),
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :remove_attachment

