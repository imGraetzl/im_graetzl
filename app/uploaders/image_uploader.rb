class ImageUploader < Shrine
  ALLOWED_TYPES  = %w[image/jpeg image/png image/webp]

  plugin :validation_helpers
  Attacher.validate do
    validate_max_size 3.megabytes, message: "size must not be greater than 3 MB"
    validate_mime_type ALLOWED_TYPES, message: "must be JPEG, PNG or WEBP"
  end

  plugin :default_url
  Attacher.default_url do |derivative: nil, **|
    file&.url if derivative
  end

end
