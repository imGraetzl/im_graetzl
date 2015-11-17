context.instance_eval do
  columns do
    column do
      panel 'User Details' do
        attributes_table_for user do
          row :id
          row :slug
          row :graetzl
          row :username
          row :first_name
          row :last_name
          row :email
          row(:role){|u| status_tag(u.role)}
          row :bio
          row :website
          row :cover_photo do |u|
            u.cover_photo ? cover_photo_for(u, fill: [200,100]) : nil
          end
          row :avatar do |u|
            u.avatar ? avatar_for(u, fill: [100,100]) : nil
          end
          row :created_at
          row :confirmed_at
          row :updated_at
          row :last_sign_in_at
          row :newsletter
        end
      end
      if user.address
        panel 'Address Details' do
          attributes_table_for user.address do
            row :id
            row :description
            row(:street){|a| "#{a.street_name}, #{a.street_number}"}
            row(:place){|a| "#{a.zip}, #{a.city}"}
            row :coordinates
          end
        end
      end
      if user.curator
        panel 'Grätzlbotschafter' do
          attributes_table_for user.curator do
            row :id
            row :graetzl
            row :created_at
          end
        end
      end
    end
    column span: 2 do
      panel 'Associations' do
        tabs do
          tab 'Pinnwand' do
            table_for user.wall_comments do
              column :id
              column :user
              column :created_at
            end
          end
          tab 'Treffen' do
            table_for user.meetings do
              column :id
              column :name
              column :slug
              column :initiator
              column :created_at
              column(''){|m| link_to 'Anzeigen', admin_meeting_path(m) }
            end
          end
          tab 'Beiträge' do
            table_for user.posts do
              column :id
              column(:content){|p| truncate(p.content, length: 20)}
              column :slug
              column :graetzl
              column :created_at
              column(''){|p| link_to 'Anzeigen', admin_post_path(p) }
            end
          end
          tab 'Locations' do
            table_for user.locations do
              column :id
              column :name
              column(:state){|l| status_tag(l.state)}
              column(''){|l| link_to 'Location Anzeigen', admin_location_path(l) }
            end
          end
        end
      end
    end
  end
end
