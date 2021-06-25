class GalleryImageUploader < ImageUploader

  plugin :derivatives, create_on_promote: true
  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    {
      thumb: magick.resize_to_fill!(200, 200),
      cardbox: {
        small: magick.resize_to_fill!(300, 220),
        large: magick.resize_to_fill!(600, 440),
      }
    }
  end

end
