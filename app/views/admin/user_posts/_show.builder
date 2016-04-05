context.instance_eval do
  attributes_table do
    row :author
    row :graetzl
    row :title
    row :content
    row :images do
      user_post.images.each do |image|
        div { attachment_image_tag(image, :file, :limit, 600, 300) }
      end
    end
    row :created_at
  end
end
