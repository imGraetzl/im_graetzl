context.instance_eval do
  columns do
    column do
      panel 'Basic Details' do
        attributes_table_for location do
          row :id
          row :region
          row :name
          row :location_category
          row :products do |location|
            safe_join(location.products.map { |p| link_to(p.name, admin_tag_path(p)) }, ', ')
          end
          row(:state){|l| status_tag(l.state)}
          row :slug
          row :created_at
          row :updated_at
          row :graetzl
          row :slogan
          row :description
          row :cover_photo do |l|
            l.cover_photo && image_tag(l.cover_photo_url(:thumb))
          end
          row :avatar do |l|
            l.avatar && image_tag(l.avatar_url(:thumb))
          end
        end
      end
      panel 'Contact Details' do
        attributes_table_for location.contact do
          row :id
          row :online_shop
          row :website
          row :email
          row :phone
          row :hours
        end
      end
      if location.address
        panel 'Address Details' do
          attributes_table_for location.address do
            row :id
            row :description
            row(:street){|a| a.street}
            row(:place){|a| "#{a.zip}, #{a.city}"}
            row :coordinates
          end
        end
      end
      if location.billing_address
        panel 'Billing Address Details' do
          attributes_table_for location.billing_address do
            row :id
            row :first_name
            row :last_name
            row :company
            row :street
            row :zip
            row :city
            row :country
          end
        end
      end
    end
    column do
      panel 'User' do
        table_for location.user do
          column(:id){|u| u.id}
          column(:username){|u| u.username}
          column(''){|u| link_to 'User Anzeigen', admin_user_path(u) }
        end
      end
      panel 'Zuckerl' do
        table_for location.zuckerls do
          column :id
          column :title
          column(:aasm_state){|z| status_tag(z.aasm_state)}
          column(''){|z| link_to 'Anzeigen', admin_zuckerl_path(z) }
        end
      end
      panel 'Treffen' do
        table_for location.meetings do
          column :id
          column :name
          column :created_at
          column(''){|m| link_to 'Anzeigen', admin_meeting_path(m) }
        end
      end
    end
  end
end
