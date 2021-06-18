class CoverImageUploader < ImageUploader

  plugin :derivatives, create_on_promote: true
  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    {
      thumb: magick.resize_to_fill!(100, 100),
      header: {
        small: magick.resize_to_fill!(375, 300),
        large: magick.resize_to_fill!(980, 400),
        huge:  magick.resize_to_fill!(1960, 800),
      },
      photo: {
        small: magick.resize_to_fill!(300, 220),
        large: magick.resize_to_fill!(600, 440),
      }
    }
  end

end
