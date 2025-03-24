context.instance_eval do
  columns do
    column do
      panel 'Unterstützungs Details' do
        attributes_table_for crowd_pledge do
          row :user
          row :Details do
            link_to('User Unterstützungsdetail Seite','/crowd_pledges/'+crowd_pledge.id+'/details', target: 'blank')
          end
          row(:status){|r| status_tag(r.status)}
          row :debited_at
          row :total_overall_price
          row :total_price
          row :donation_amount
          row :inclomplete_reminder_sent_at
        end
        attributes_table_for crowd_pledge.crowd_reward do
          row :amount
          row :title
          row :answer
        end
      end
    end
    column do
      panel 'Unterstützung' do
        attributes_table_for crowd_pledge do
          row :crowd_campaign
          row :id
          row :email
          row :contact_name
          row :user
          row :created_at
          row :updated_at
        end
      end
      panel 'Crowd Boost Charge' do
        attributes_table_for crowd_pledge do
          row :crowd_boost_charge_percentage
          row :crowd_boost_charge_amount
          row :crowd_boost_id
        end
      end
    end
  end
  panel 'Kontaktdaten' do
    attributes_table_for crowd_pledge do
      row :anonym
      row :guest_newsletter
      row :contact_name
      row :address_street
      row :address_zip
      row :address_city
    end
  end

  panel 'Stripe Informationen' do
    attributes_table_for crowd_pledge do
      row :stripe_customer_id
      row :stripe_payment_method_id
      row :stripe_payment_intent_id
      row :payment_method
      row :payment_card_last4
      row :payment_wallet
    end
  end

  panel 'User Agent' do
    attributes_table_for crowd_pledge do
      if crowd_pledge.user_agent
        row(:browser_platform){|p| p.user_agent["browser_platform"]}
        row(:browser_platform_id){|p| p.user_agent["browser_platform_id"]}
        row(:browser_platform_name){|p| p.user_agent["browser_platform_name"]}
        row(:browser_platform_version){|p| p.user_agent["browser_platform_version"]}
        row(:browser_name){|p| p.user_agent["browser_name"]}
        row(:browser_full_version){|p| p.user_agent["browser_full_version"]}
        row(:browser_device_id){|p| p.user_agent["browser_device_id"]}
        row(:browser_device_name){|p| p.user_agent["browser_device_name"]}
      end
    end
  end

end
