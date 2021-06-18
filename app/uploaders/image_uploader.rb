class ImageUploader < Shrine
  ALLOWED_TYPES  = %w[image/jpeg image/png image/webp]

  plugin :validation_helpers
  Attacher.validate do
    validate_max_size 3.megabytes
    validate_mime_type ALLOWED_TYPES
  end

  plugin :default_url
  Attacher.default_url do |derivative: nil, **|
    file&.url if derivative
  end

end
