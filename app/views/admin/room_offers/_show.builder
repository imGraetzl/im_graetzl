context.instance_eval do
  columns do
    column do
      panel 'Room Offer Details' do
        attributes_table_for room_offer do
          row :id
          row :region
          row :graetzl
          row(:status){|r| status_tag(r.status)}
          row :offer_type
          row :slogan
          row :slug
          row :created_at
          row :updated_at
          row :last_activated_at
          row :room_description
          row :owner_description
          row :tenant_description
          row :total_area
          row :rented_area
          row :wants_collaboration
          row :rental_enabled
          row :keyword_list

          row :room_categories do |g|
            safe_join(
              g.room_categories.map do |category|
                content_tag(:span, link_to(category.name, admin_room_category_path(category)))
              end
            )
          end

          row :cover_photo do |r|
            r.cover_photo && image_tag(r.cover_photo_url(:thumb))
          end
          row :avatar do |r|
            r.avatar && image_tag(r.avatar_url(:thumb))
          end
          row :images do
            room_offer.images.map do |image|
              image_tag image.file_url(:thumb)
            end
          end
        end
      end

      panel 'Address Details' do
        attributes_table_for room_offer do
          row :address_street
          row :address_zip
          row :address_city
          row :address_coordinates
          row :address_description
        end
      end

      panel 'Contact Details' do
        attributes_table_for room_offer do
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
            table_for room_offer.user do
              column(:id){|u| u.id}
              column(:username){|u| u.username}
              column(:role){|u| status_tag(u.role)}
              column(''){|u| link_to 'User Anzeigen', admin_user_path(u) }
            end
          end
          tab 'Location' do
            table_for(room_offer.location || []) do
              column :id
              column :name
              column(:state){|l| status_tag(l.state)}
              column :slug
              column :created_at
              column(''){|l| link_to 'Anzeigen', admin_location_path(l) }
            end
          end
          tab 'Comments' do
            table_for room_offer.comments do
              column(:id){|c| c.id}
              column(:username){|c| c.user.username}
              column(:created_at)
            end
          end

        end
      end
      panel 'Rent Requests' do
        table_for room_offer.room_rentals do
          column :id
          column :renter
          column(:rental_status){|r| status_tag(r.rental_status)}
          column(''){|l| link_to 'Anzeigen', admin_room_rental_path(l) }
        end
      end
    end
  end
end
