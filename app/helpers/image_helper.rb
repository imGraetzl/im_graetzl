module ImageHelper

  def avatar_image(object, size: nil, **options)
    if object&.avatar.nil?
      avatar_type = object.is_a?(Location) ? 'location' : 'user'
      image_tag("fallbacks/#{avatar_type}_avatar.png", loading: 'lazy', alt: object.to_s, **options)
    elsif size
      image_tag(object.avatar_url(size), loading: 'lazy', alt: object.to_s, **options)
    else
      image_tag(object.avatar_url(:large), loading: 'lazy', srcset: {
        object.avatar_url(:small) => '200w',
        object.avatar_url(:large) => '400w',
      }, sizes: "(min-width: 650px) 400px, 200px", alt: object.to_s, **options)
    end
  end

  def avatar_image_with_tooltip(object, size: nil, additional: nil, **options)
    options[:class] = "#{options[:class]} avatar-tooltip-trigger"
    tooltip_data = {
      tooltip_id: "#{object.class.name.parameterize}-tooltip-#{object.id}-#{rand(1000)}",
      url: url_for([:tooltip, object.class.name.parameterize.to_sym, id: object.id, additional: additional]),
      tooltip_type: object.class.name,
    }
    avatar_image(object, size: size, loading: 'lazy', data: tooltip_data, **options)
  end

  def cover_url(object, size)
    object&.cover_photo_url(:cardbox, size).presence ||
    image_url("fallbacks/cover_photo.png")
  end

  def cover_header_image(object, size: nil, fallback: "cover_header.png", **options)
    if object&.cover_photo.nil?
      image_tag("fallbacks/#{fallback}", loading: 'lazy', alt: object.to_s, **options)
    elsif size
      image_tag(object.cover_photo_url(:header, size), loading: 'lazy', alt: object.to_s, **options)
    elsif File.extname(object.cover_photo_url(:header, :large_webp)) == '.webp'
      content_tag :picture do
        tag(:source, srcset: object.cover_photo_url(:header, :large_webp)) +
        image_tag(object.cover_photo_url(:header, :large), loading: 'lazy', alt: object.to_s, **options)
      end
    else
      image_tag(object.cover_photo_url(:header, :large), srcset: {
        object.cover_photo_url(:header, :small) => '375w',
        object.cover_photo_url(:header, :medium) => '750w',
        object.cover_photo_url(:header, :large) => '980w',
      }, sizes: "(min-width: 980px) 980px, 100vw", loading: 'lazy', alt: object.to_s, **options)
    end
  end

  def cover_photo_image(object, size: nil, fallback: "cover_photo.png", **options)
    if object&.cover_photo.nil?
      image_tag("fallbacks/#{fallback}", loading: 'lazy', alt: object.to_s, **options)
    elsif size
      image_tag(object.cover_photo_url(:cardbox, size), loading: 'lazy', alt: object.to_s, **options)
    elsif File.extname(object.cover_photo_url(:cardbox, :large_webp)) == '.webp'
      content_tag :picture do
        tag(:source, srcset: object.cover_photo_url(:cardbox, :large_webp)) +
        image_tag(object.cover_photo_url(:cardbox, :large), loading: 'lazy', alt: object.to_s, **options)
      end
    else
      image_tag(object.cover_photo_url(:cardbox, :small), srcset: {
        object.cover_photo_url(:cardbox, :small) => '1x',
        object.cover_photo_url(:cardbox, :large) => '2x',
      }, loading: 'lazy', alt: object.to_s, **options)
    end
  end

  def category_image(object, **options)
      if File.extname(object.main_photo_url(:large_webp)) == '.webp'
        content_tag :picture do
          tag(:source, srcset: object.main_photo_url(:large_webp)) +
          image_tag(object.main_photo_url(:large), loading: 'lazy', alt: object.to_s, **options)
        end
      else
        image_tag(object.main_photo_url(:small), srcset: {
          object.main_photo_url(:small) => '1x',
          object.main_photo_url(:large) => '2x',
        }, loading: 'lazy', alt: object.to_s, **options)
    end
  end

  def gallery_thumb_image(object, **options)
    image_tag(object.file_url(:thumb), loading: 'lazy', **options)
  end

  def gallery_photo_image(object, fallback: 'cover_photo.png', **options)
    if object&.file.nil?
      image_tag("fallbacks/#{fallback}", loading: 'lazy', **options)
    else
      image_tag(object.file_url(:cardbox, :small), srcset: {
        object.file_url(:cardbox, :small) => '1x',
        object.file_url(:cardbox, :large) => '2x',
      }, loading: 'lazy', alt: object.to_s, **options)
    end
  end

end
