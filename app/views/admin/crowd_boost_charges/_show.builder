context.instance_eval do
  columns do
    column do
      panel 'Einzahlungs Details' do
        attributes_table_for crowd_boost_charge do
          row :user
          row :Details do
            link_to('User Unterstützungsdetail Seite','/crowd-boost-charge/'+crowd_boost_charge.id+'/details', target: 'blank')
          end
          row(:status){|r| status_tag(r.payment_status)}
          row :debited_at
          row :amount
        end
      end
    end
    column do
      panel 'Einzahlung' do
        attributes_table_for crowd_boost_charge do
          row :crowd_boost
          row :id
          row :email
          row :contact_name
          row :user
          row :created_at
          row :updated_at
        end
      end
    end
  end
  panel 'Kontaktdaten' do
    attributes_table_for crowd_boost_charge do
      row :contact_name
      #row :address_street
      #row :address_zip
      #row :address_city
    end
  end

  panel 'Stripe Informationen' do
    attributes_table_for crowd_boost_charge do
      row :stripe_customer_id
      row :stripe_payment_method_id
      row :stripe_payment_intent_id
      row :payment_method
      row :payment_card_last4
      row :payment_wallet
    end
  end

end
