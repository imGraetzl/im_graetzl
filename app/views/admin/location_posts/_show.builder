context.instance_eval do
  attributes_table do
    row :location
    row :graetzl
    row :title
    row :content
    row :images do
      location_post.images.map do |image|
        image_tag image.file_url(:thumb)
      end
    end
    row :created_at
  end
end
