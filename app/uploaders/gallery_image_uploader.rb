class GalleryImageUploader < ImageUploader

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    {
      thumb: magick.resize_to_fill!(200, 200),
      thumb_webp: magick.convert("webp").resize_to_fill!(200, 200),
      cardbox: {
        small: magick.resize_to_fill!(300, 220),
        large: magick.resize_to_fill!(600, 440),
      }
    }
  end

end
