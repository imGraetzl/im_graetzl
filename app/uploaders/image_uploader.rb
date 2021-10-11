class ImageUploader < Shrine
  ALLOWED_TYPES  = %w[image/jpeg image/png image/webp]

  plugin :validation_helpers
  Attacher.validate do
    validate_max_size 5.megabytes, message: "darf maximal 5MB groß sein"
    validate_mime_type ALLOWED_TYPES, message: "muss das Format JPEG, PNG or WEBP haben"
  end

  plugin :default_url
  Attacher.default_url do |derivative: nil, **|
    file&.url if derivative
  end

end
