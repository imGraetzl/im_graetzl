class CoverImageUploader < ImageUploader

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    {
      thumb: magick.resize_to_fill!(200, 200),
      header: {
        small:  magick.resize_to_fill!(375, 300),
        medium: magick.resize_to_fill!(750, 600),
        large:  magick.resize_to_fill!(980, 400),
        large_webp: magick.convert("webp").resize_to_fill!(980, 400)
      },
      cardbox: {
        small: magick.resize_to_fill!(300, 220),
        large: magick.resize_to_fill!(600, 440),
        large_webp: magick.convert("webp").resize_to_fill!(600, 440)
      }
    }
  end

end
