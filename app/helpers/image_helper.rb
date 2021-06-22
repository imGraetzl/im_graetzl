module ImageHelper

  def avatar_url(object, size)
    avatar_type = object.is_a?(Location) ? 'location' : 'user'
    object&.avatar_url(size).presence ||
    image_url("fallbacks/#{avatar_type}_avatar.png")
  end

  def avatar_image(object, size: nil, **options)
    if object&.avatar.nil?
      avatar_type = object.is_a?(Location) ? 'location' : 'user'
      image_tag("fallbacks/#{avatar_type}_avatar.png", alt: object.to_s, **options)
    elsif size
      image_tag(object.avatar_url(size), alt: object.to_s, **options)
    else
      image_tag(object.avatar_url(:large), srcset: {
        object.avatar_url(:small) => '200w',
        object.avatar_url(:large) => '400w',
        object.avatar_url(:huge) => '800w',
      }, sizes: "(min-width: 800px) 800px, 100vw", alt: object.to_s, **options)
    end
  end

  def avatar_image_with_tooltip(object, size: nil, additional: nil, **options)
    options[:class] = "#{options[:class]} avatar-tooltip-trigger"
    tooltip_data = {
      tooltip_id: "#{object.class.name.parameterize}-tooltip-#{object.id}-#{rand(1000)}",
      url: url_for([:tooltip, object.class.name.parameterize.to_sym, id: object.id, additional: additional]),
      tooltip_type: object.class.name,
    }
    avatar_image(object, size: size, data: tooltip_data, **options)
  end

  def cover_url(object, size)
    object&.cover_photo_url(:photo, size).presence ||
    image_url("fallbacks/cover_photo.png")
  end

  def cover_header_image(object, size: nil, **options)
    if object&.cover_photo.nil?
      image_tag("fallbacks/cover_header.png", alt: object.to_s, **options)
    elsif size
      image_tag(object.cover_photo_url(:header, size), alt: object.to_s, **options)
    else
      image_tag(object.cover_photo_url(:header, :desktop_1x), srcset: {
        object.cover_photo_url(:header, :phone_1x) => '375w',
        object.cover_photo_url(:header, :phone_2x) => '750w',
        object.cover_photo_url(:header, :desktop_1x) => '980w',
        object.cover_photo_url(:header, :desktop_2x) => '1960w',
      }, sizes: "(min-width: 1960px) 1960px, (min-width: 1440px) 980px, 100vw", alt: object.to_s, **options)
    end
  end

  def cover_photo_image(object, size: nil, **options)
    if object&.cover_photo.nil?
      image_tag("fallbacks/cover_photo.png", alt: object.to_s, **options)
    elsif size
      image_tag(object.cover_photo_url(:photo, size), alt: object.to_s, **options)
    else
      image_tag(object.cover_photo_url(:photo, :large), srcset: {
        object.cover_photo_url(:photo, :small) => '1x',
        object.cover_photo_url(:photo, :large) => '2x',
      }, alt: object.to_s, **options)
    end
  end

  def category_image(object, **options)
    image_tag(object.main_photo_url(:small), srcset: {
      object.main_photo_url(:small) => '1x',
      object.main_photo_url(:large) => '2x',
    }, alt: object.to_s, **options)
  end

  def gallery_photo_image(object, **options)
    image_tag(object.file_url(:photo, :small), srcset: {
      object.file_url(:photo, :small) => '1x',
      object.file_url(:photo, :large) => '2x',
    }, alt: object.to_s, **options)
  end

end