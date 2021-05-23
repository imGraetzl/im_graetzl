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

## Migration dual write

Shrine.plugin :model

module RefileShrineSynchronization
  def write_shrine_data(name)
    attacher = Shrine::Attacher.from_model(self, name)

    if read_attribute("#{name}_id").present?
      attacher.set shrine_file(name)
    else
      attacher.set nil
    end
  end

  def shrine_file(name)
    Shrine.uploaded_file(
      storage:  :store,
      id:       send("#{name}_id"),
      metadata: {
        "size"      => (send("#{name}_size") if respond_to?("#{name}_size")),
        "filename"  => (send("#{name}_filename") if respond_to?("#{name}_filename")),
        "mime_type" => (send("#{name}_content_type") if respond_to?("#{name}_content_type")),
      }
    )
  end
end
