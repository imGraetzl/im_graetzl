context.instance_eval do
  columns do
    column do
      panel 'User Details' do
        attributes_table_for user do
          row :id
          row :region
          row :graetzl
          row :slug
          row :username
          row "Benachrichtigungen" do |u|
            link_to "Mail-Einstellungen von #{u.username}", admin_user_notification_settings_path(q: { id_eq: u.id })
          end
          row :first_name
          row :last_name
          row :email
          row :business
          row(:newsletter){|u| status_tag(u.newsletter)}
          row(:role){|u| status_tag(u.role)}
          row :stripe_connect_account_id
          row :stripe_connect_ready
          row :location_category
          row :business_interests do |g|
            safe_join(
              g.business_interests.map do |interest|
                content_tag(:li, link_to(interest.title, admin_business_interest_path(interest)))
              end
            )
          end

          row :bio
          row :website
          row :cover_photo do |u|
            u.cover_photo && image_tag(u.cover_photo_url(:thumb))
          end
          row :avatar do |u|
            u.avatar && image_tag(u.avatar_url(:thumb))
          end
          row :created_at
          row :confirmed_at
          row :updated_at
          row :last_sign_in_at
          row :origin
        end
      end

      panel 'Address Details' do
        attributes_table_for user do
          row :address_street
          row :address_zip
          row :address_city
          row :address_coordinates
          row :address_description
        end
      end

    end
    column do

      panel 'Locations' do
        table_for user.locations do
          column :id
          column :name
          column(:state){|l| status_tag(l.state)}
          column(''){|l| link_to 'Anzeigen', admin_location_path(l) }
        end
      end

      panel 'Toolteiler' do
        table_for user.tool_offers do
          column :id
          column :title
          column(:state){|l| status_tag(l.status)}
          column(''){|l| link_to 'Anzeigen', admin_tool_offer_path(l) }
        end
      end

      panel 'Raumteiler | Habe Raum' do
        table_for user.room_offers do
          column :id
          column :slogan
          column(:comment_count) {|r| r.comments.size }
          column(''){|l| link_to 'Anzeigen', admin_room_offer_path(l) }
        end
      end

      panel 'Raumteiler | Suche Raum' do
        table_for user.room_demands do
          column :id
          column :slogan
          column(:comment_count) {|r| r.comments.size }
          column(''){|l| link_to 'Anzeigen', admin_room_demand_path(l) }
        end
      end

      panel 'Gruppen Mitglied' do
        table_for user.groups do
          column :id
          column :title
          column(''){|l| link_to 'Anzeigen', admin_group_path(l) }
        end
      end

      panel 'Associations' do
        tabs do
          tab 'Erstellte Treffen' do
            table_for user.initiated_meetings do
              column :id
              column :name
              column :user
              column :created_at
              column(''){|m| link_to 'Anzeigen', admin_meeting_path(m) }
            end
          end
          tab 'Pinnwand' do
            table_for user.wall_comments do
              column :id
              column :user
              column :created_at
            end
          end
        end
      end
    end
  end
end
