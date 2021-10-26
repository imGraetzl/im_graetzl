context.instance_eval do
  columns do
    column do
      panel 'Tool Demand Details' do
        attributes_table_for tool_demand do
          row :id
          row :region
          row :slogan
          row(:state){|l| status_tag(l.status)}
          row :usage_period
          row :usage_period_from
          row :usage_period_to
          row :usage_days
          row :demand_description
          row :usage_description
          row :slug
          row :created_at
          row :updated_at
          row :keyword_list
          row :images do
            tool_demand.images.map do |image|
              image_tag image.file_url(:thumb)
            end
          end
        end
      end

      panel 'Contact Details' do
        attributes_table_for tool_demand do
          row :first_name
          row :last_name
        end
      end
    end

    column do
      panel 'Associations' do
        tabs do
          tab 'User' do
            table_for tool_demand.user do
              column(:id){|u| u.id}
              column(:username){|u| u.username}
              column(:role){|u| status_tag(u.role)}
              column(''){|u| link_to 'User Anzeigen', admin_user_path(u) }
            end
          end
          tab 'Location' do
            table_for(tool_demand.location || []) do
              column :id
              column :name
              column(:state){|l| status_tag(l.state)}
              column :slug
              column :created_at
              column(''){|l| link_to 'Anzeigen', admin_location_path(l) }
            end
          end
          tab 'Comments' do
            table_for tool_demand.comments do
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
