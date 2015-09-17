module ImagesHelper
  def cover_photo_for(model, options={})
    options = cover_photo_defaults.merge(options)
    attachment_image_tag(model, :cover_photo,
                                :fill, options[:fill][0], options[:fill][1],
                                fallback: stock_photo(options),
                                class: options[:class])
  end

  def avatar_for(model, options={})
    options = avatar_defaults.merge(options)
    attachment_image_tag(model, :avatar,
                                :fill, options[:fill][0], options[:fill][1],
                                fallback: stock_avatar(model, options),
                                class: options[:class])    
  end


  private

  def cover_photo_defaults
    { fill: [300,180], class: 'coverImg' }
  end

  def avatar_defaults
    { fill: [100,100], class: 'img-round' }
  end

  def stock_photo(opt)
    alpha_img = "cover_photo/#{opt[:fill].join('x')}.png"
    if Rails.application.assets.find_asset(alpha_img).blank?
      return "https://placeimg.com/#{opt[:fill].join('/')}/nature/grayscale"
    end
    alpha_img
  end

  def stock_avatar(model, opt)
    type = model.model_name.human.downcase
    default_img = "avatar/#{type}/#{opt[:fill].join('x')}.png"
    if Rails.application.assets.find_asset(default_img).blank?
      return "avatar/#{type}/default.png"
    end
    default_img
  end
end
