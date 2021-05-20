module AttachmentsHelper

  def avatar_url(object, size)
    object&.avatar_url(size).presence || avatar_fallback_url(size, object.is_a?(Location) ? 'location' : 'user')
  end

  def avatar_fallback_url(size, type)
    case size
    when :thumb then image_url("avatar/#{type}/100x100.png")
    when :small then image_url("avatar/#{type}/200x200.png")
    when :large then image_url("avatar/#{type}/400x400.png")
    end
  end

  def cover_url(object, size)
    object&.cover_photo_url(size).presence || cover_fallback_url(size)
  end

  def cover_fallback_url(size)
    case size
    when :thumb then image_url("avatar/user/100x100.png")
    when :small then image_url("cover_photo/300x180.png")
    when :large then image_url("cover_photo/980x370.png")
    end
  end

  def category_photo_url(object)
    object&.main_photo_url(:large).presence || image_url("cover_photo/200x200.png")
  end

  def avatar_for(resource, size=200, form=nil)
    if form.nil?
      css_class = resource.is_a?(User) || resource.is_a?(RoomOffer) || resource.is_a?(RoomDemand) ? 'img-round avatar' : 'img-square avatar'
    else
      css_class = form
    end

    if size <= 100
      size = :thumb
    elsif size <= 200
      size = :small
    else
      size = :large
    end

    image_tag(avatar_url(resource, size), class: css_class)
  end

  # USER Avatar with Tooltip
  def user_tooltip_avatar(user, size=200, css=nil, additionalInfo=nil)
    if css.nil?
      css_class = 'img-round user-tooltip-trigger'
    else
      css_class = css
    end
    if additionalInfo.nil?
      additional = ''
    else
      additional = "&additional=#{additionalInfo}"
    end
    fallback = "avatar/user/200x200.png"
    tooltip_id = "user-tooltip-#{user.id}-#{rand(1000)}"
    tooltip_url = "/user/tooltip?id=#{user.id}#{additional}"
    image_tag(avatar_url(user, :small), class: css_class, data: { tooltip_id: tooltip_id, url: tooltip_url, tooltip_type: 'User' })
  end

  # LOCATION Avatar with Tooltip
  def location_tooltip_avatar(location, size=200, css=nil, additionalInfo=nil)
    if css.nil?
      css_class = 'img-square user-tooltip-trigger'
    else
      css_class = css
    end
    if additionalInfo.nil?
      additional = ''
    else
      additional = "&additional=#{additionalInfo}"
    end
    fallback = "avatar/location/200x200.png"
    tooltip_id = "location-tooltip-#{location.id}-#{rand(1000)}"
    tooltip_url = "/location/tooltip?id=#{location.id}#{additional}"
    image_tag(avatar_url(location, :small), class: css_class, data: { tooltip_id: tooltip_id, url: tooltip_url, tooltip_type: 'Location' })
  end

end
