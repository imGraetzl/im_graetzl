class AvatarUploader < ImageUploader

  plugin :derivatives, create_on_promote: true
  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    {
      thumb: magick.resize_to_fill!(100, 100),
      small: magick.resize_to_fill!(200, 200),
      large: magick.resize_to_fill!(400, 400),
      thumb_webp: magick.convert("webp").resize_to_fill!(100, 100),
      small_webp: magick.convert("webp").resize_to_fill!(200, 200),
      large_webp: magick.convert("webp").resize_to_fill!(400, 400),
    }
  end

end
