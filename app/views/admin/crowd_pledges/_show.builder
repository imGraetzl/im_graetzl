context.instance_eval do
  columns do
    column do
      panel 'Unterstützungs Details' do
        attributes_table_for crowd_pledge do
          row(:status){|r| status_tag(r.status)}
          row :total_price
          row :donation_amount
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
    end
  end

end