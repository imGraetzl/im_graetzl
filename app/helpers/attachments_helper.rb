module AttachmentsHelper
  def avatar_for(resource, size=200, form=nil)
    if form.nil?
      css_class = resource.is_a?(User) ? 'img-round' : 'img-square'
    else
      css_class = form
    end
    if resource.nil?
      fallback = "http://via.placeholder.com/200x200"
    else
      fallback = "avatar/#{resource.model_name.human.downcase}/200x200.png"
    end
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
