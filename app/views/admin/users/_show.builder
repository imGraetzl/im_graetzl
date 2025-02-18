context.instance_eval do
  columns do
    column do
      panel 'User Details' do
        attributes_table_for user do
          row :id
          row :guest
          if current_user.superadmin?
            row "Login als User" do |u|
              link_to "Login As", masquerade_path(user)
            end
          end
          row :free_region_zuckerl
          row :free_graetzl_zuckerl
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
          row :current_sign_in_at
          row :last_sign_in_at
          row :sign_in_count
          row :deleted_at
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

      panel 'Payment Details' do
        attributes_table_for user do
          row :stripe_customer_id
          row :payment_method
          row :payment_card_last4
          row :payment_wallet
          row :stripe_connect_account_id
          row :stripe_connect_ready
          row :iban
        end
      end

    end
    column do

      panel 'Subscriptions' do
        table_for user.subscriptions do
          column :id
          column(:subscription_plan) {|p| p.subscription_plan.amount }
          column(:status){|l| status_tag(l.status)}
          column(''){|l| link_to 'Anzeigen', admin_subscription_path(l) }
        end
      end

      panel 'Schaufenster' do
        table_for user.locations do
          column :id
          column :name
          column(:state){|l| status_tag(l.state)}
          column(''){|l| link_to 'Anzeigen', admin_location_path(l) }
        end
      end

      panel 'Raumteiler | Habe Raum' do
        table_for user.room_offers do
          column :id
          column :slogan
          column(:status){|r| status_tag(r.status)}
          column(''){|l| link_to 'Anzeigen', admin_room_offer_path(l) }
        end
      end

      panel 'Raumteiler | Suche Raum' do
        table_for user.room_demands do
          column :id
          column :slogan
          column(:status){|r| status_tag(r.status)}
          column(''){|l| link_to 'Anzeigen', admin_room_demand_path(l) }
        end
      end

      panel 'Geräteteiler' do
        table_for user.tool_offers do
          column :id
          column :title
          column(:state){|l| status_tag(l.status)}
          column(''){|l| link_to 'Anzeigen', admin_tool_offer_path(l) }
        end
      end

      panel 'Gruppen Mitglied' do
        table_for user.groups do
          column :id
          column :title
          column(''){|l| link_to 'Anzeigen', admin_group_path(l) }
        end
      end

      panel 'Treffen' do
        tabs do
          tab 'Zukünftige Treffen' do
            table_for user.initiated_meetings.upcoming do
              column :id
              column :name
              column(:status){|r| status_tag(r.state)}
              column :starts_at_date
              column(''){|m| link_to 'Anzeigen', admin_meeting_path(m) }
            end
          end
          tab 'Erstellte Treffen' do
            table_for user.initiated_meetings do
              column :id
              column :name
              column(:status){|r| status_tag(r.state)}
              column :starts_at_date
              column(''){|m| link_to 'Anzeigen', admin_meeting_path(m) }
            end
          end
        end
      end

      panel 'Crowdfunding Unterstützungen' do
        table_for user.crowd_pledges.order(created_at: :desc) do
          column :total_price
          column(:status){|c| status_tag(c.status)}
          column(''){|c| link_to c.crowd_campaign, admin_crowd_pledge_path(c) }
        end
      end

    end
  end
end
