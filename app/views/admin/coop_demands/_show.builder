context.instance_eval do
  columns do
    column do
      panel 'Coop & Share Details' do
        attributes_table_for coop_demand do
          row :id
          row(:status){|r| status_tag(r.status)}
          row :coop_type
          row :coop_demand_category
          row :slogan
          row :slug
          row :created_at
          row :updated_at
          row :last_activated_at
          row :demand_description
          row :personal_description
          row :avatar do |r|
            r.avatar && image_tag(r.avatar_url(:thumb))
          end
        end
      end

      panel 'Contact Details' do
        attributes_table_for coop_demand do
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
            table_for coop_demand.user do
              column(:id){|u| u.id}
              column(:username){|u| u.username}
              column(:role){|u| status_tag(u.role)}
              column(''){|u| link_to 'User Anzeigen', admin_user_path(u) }
            end
          end
          tab 'Location' do
            table_for(coop_demand.location || []) do
              column :id
              column :name
              column(:state){|l| status_tag(l.state)}
              column :slug
              column :created_at
              column(''){|l| link_to 'Anzeigen', admin_location_path(l) }
            end
          end
          tab 'Comments' do
            table_for coop_demand.comments do
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
