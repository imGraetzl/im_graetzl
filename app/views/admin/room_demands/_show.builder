context.instance_eval do
  columns do
    column do
      panel 'Room Offer Details' do
        attributes_table_for room_demand do
          row :id
          row(:status){|r| status_tag(r.status)}
          row(:entire_region){|r| status_tag(r.entire_region)}
          row :demand_type
          row :slogan
          row :slug
          row :created_at
          row :updated_at
          row :last_activated_at
          row :needed_area
          row :demand_description
          row :personal_description
          row :wants_collaboration

          row :room_categories do |g|
            safe_join(
              g.room_categories.map do |category|
                content_tag(:li, link_to(category.name, admin_room_category_path(category)))
              end
            )
          end

          row :avatar do |r|
            r.avatar && image_tag(r.avatar_url(:thumb))
          end
        end
      end

      panel 'Contact Details' do
        attributes_table_for room_demand do
          row :first_name
          row :last_name
          row :website
          row :email
          row :phone
        end
      end
    end

    column do
      panel 'Associations' do
        tabs do
          tab 'User' do
            table_for room_demand.user do
              column(:id){|u| u.id}
              column(:username){|u| u.username}
              column(:role){|u| status_tag(u.role)}
              column(''){|u| link_to 'User Anzeigen', admin_user_path(u) }
            end
          end
          tab 'Location' do
            table_for(room_demand.location || []) do
              column :id
              column :name
              column(:state){|l| status_tag(l.state)}
              column :slug
              column :created_at
              column(''){|l| link_to 'Anzeigen', admin_location_path(l) }
            end
          end
          tab 'Comments' do
            table_for room_demand.comments do
              column(:id){|c| c.id}
              column(:username){|c| c.user.username}
              column(:created_at)
            end
          end

        end
      end
    end
  end
end
