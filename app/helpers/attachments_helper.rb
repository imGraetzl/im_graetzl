module AttachmentsHelper
  def avatar_for(resource, size=200)
    css_class = resource.is_a?(User) ? 'img-round' : 'img-square'
    fallback = "avatar/#{resource.model_name.human.downcase}/200x200.png"
    attachment_image_tag(resource, :avatar,
                                  :fill, size, size,
                                  class: css_class,
                                  fallback: fallback)
  end

  def cover_photo_for(resource)
    attachment_image_tag(resource, :cover_photo,
                                  :fill, 300, 180,
                                  class: 'coverImg',
                                  fallback: 'cover_photo/300x180.png')
  end
end
