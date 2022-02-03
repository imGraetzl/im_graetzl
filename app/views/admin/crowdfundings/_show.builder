context.instance_eval do
  columns do
    column do
      panel 'Basic Details' do
        attributes_table_for crowdfunding do
          row :id
          row :region
          row :graetzl
          row :title
          row :slogan
          row :crowd_categories do |e|
            safe_join(
              e.crowd_categories.map do |category|
                content_tag(:span, link_to(category.title, admin_crowd_category_path(category))) + ', '
              end
            )
          end
          row(:status){|l| status_tag(l.status)}
          row :slug
          row :created_at
          row :updated_at
          row :description
          row :cover_photo do |l|
            l.cover_photo && image_tag(l.cover_photo_url(:thumb))
          end
          row :images do
            crowdfunding.images.map do |image|
              image_tag image.file_url(:thumb)
            end
          end
        end
      end

      panel 'Contact Details' do
        attributes_table_for crowdfunding do
          row :id
          row :contact_name
          row :contact_email
        end
      end

    end
    column do
      if crowdfunding.user
        panel 'User' do
          table_for crowdfunding.user do
            column(:id){|u| u.id}
            column(:username){|u| u.username}
            column(''){|u| link_to 'User Anzeigen', admin_user_path(u) }
          end
        end
      end
    end
  end
end
