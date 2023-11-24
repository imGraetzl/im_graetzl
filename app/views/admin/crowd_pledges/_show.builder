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

end
