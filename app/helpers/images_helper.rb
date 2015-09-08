module ImagesHelper
  def cover_photo_for(model, options={})
    options = cover_photo_defaults.merge(options)
    attachment_image_tag(model, :cover_photo,
                                :fill, options[:fill][0], options[:fill][1],
                                fallback: options[:fallback],
                                class: options[:class])
  end

  def avatar_for(model, options={})
    options = avatar_defaults.merge(options)
    attachment_image_tag(model, :avatar,
                                :fill, options[:fill][0], options[:fill][1],
                                fallback: 'avatar/small_default.png',
                                class: options[:class])    
  end

  private
    def cover_photo_defaults
      { fill: [300,180],
        fallback: 'cover_photo/default.jpg',
        class: 'coverImg' }
    end

    def avatar_defaults
      { fill: [100,100],
        fallback: 'avatar/small_default.png',
        class: 'img-round' }
    end
end
