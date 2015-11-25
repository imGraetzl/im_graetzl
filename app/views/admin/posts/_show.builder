context.instance_eval do
  columns do
    column do
      panel 'Post Details' do
        attributes_table_for post do
          row :id
          row :slug
          row :graetzl
          row :author
          if post.author.is_a?(Location)
            row :title
          end
          row :content
          row :images do
            post.images.each do |image|
              div { attachment_image_tag(image, :file, :limit, 600, 300) }
            end
          end
        end
      end
    end
  end
end
