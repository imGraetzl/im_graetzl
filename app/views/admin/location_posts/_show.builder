context.instance_eval do
  attributes_table do
    row :location
    row :graetzl
    row :title
    row :content
    row :images do
      location_post.images.map do |image|
        attachment_image_tag image, :file, :limit, 600, 300
      end
    end
    row :created_at
  end
end
