context.instance_eval do
  columns do
    column do
      attributes_table do
        row :author
        row :title
        row :content
        row :images do
          admin_post.images.each do |image|
            div { attachment_image_tag(image, :file, :limit, 600, 300) }
          end
        end
      end
    end
    column span: 2 do
      panel 'Graetzl' do
        table_for admin_post.graetzls do
          column(:id){|graetzl| link_to graetzl.id, [:admin, graetzl]}
          column :name
        end
      end
    end
  end
end
