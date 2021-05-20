class ImageUploader < Shrine

  plugin :validation_helpers
  Attacher.validate do
    validate_max_size 3.megabytes
    validate_extension %w[jpg jpeg png webp]
  end

  plugin :derivatives, create_on_promote: true
  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    case name
    when :avatar
      {
        thumb: magick.resize_to_fill!(100, 100),
        small: magick.resize_to_fill!(200, 200),
        large: magick.resize_to_fill!(400, 400),
      }
    when :cover_photo
      {
        thumb: magick.resize_to_fill!(100, 100),
        small: magick.resize_to_fill!(300, 220),
        large: magick.resize_to_fill!(980, 420),
      }
    when :main_photo
      {
        thumb: magick.resize_to_fill!(100, 100),
        small: magick.resize_to_fill!(200, 200),
        large: magick.resize_to_fill!(400, 600),
      }
    else
      {
        small: magick.resize_to_fill!(200, 200),
        large: magick.resize_to_limit!(900, 900),
      }
    end
  end

  plugin :default_url
  Attacher.default_url do |derivative: nil, **|
    file&.url if derivative
  end

end
