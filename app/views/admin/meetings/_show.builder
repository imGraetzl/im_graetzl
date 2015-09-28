context.instance_eval do
  columns do
    column do
      panel 'Meeting Details' do
        attributes_table_for meeting do
          row :id
          row :name
          row(:state){|m| status_tag(m.state)}
          row :slug
          row :created_at
          row :updated_at
          row :graetzl
          row :location
          row :initiator
          row :description
          row :cover_photo do |m|
            m.cover_photo ? cover_photo_for(m, fill: [200,100]) : nil
          end
          row :starts_at_date
          row :starts_at_time
          row :ends_at_date
          row :ends_at_time
        end
      end
      panel 'Address Details' do
        attributes_table_for meeting.address do
          row :id
          row :description
          row(:street){|a| "#{a.street_name}, #{a.street_number}"}
          row(:place){|a| "#{a.zip}, #{a.city}"}
          row :coordinates
        end
      end
    end
    column span: 2 do
      panel 'Associations' do
        tabs do
          tab 'User' do
            table_for meeting.going_tos do
              column(:id){|g| g.user.id}
              column(:username){|g| g.user.username}
              column(:role){|g| status_tag(g.role)}
              column :created_at
              column(''){|m| link_to 'User Anzeigen', admin_user_path(m.user) }
            end
          end
        end
      end
    end
  end
end