context.instance_eval do
  columns do
    column do
      panel 'Einzahlungs Details' do
        attributes_table_for crowd_boost_charge do
          row :user
          row :contact_name
          row :Details do
            link_to('User Einzahlungsdetail Seite','/crowd-boost-charge/'+crowd_boost_charge.id+'/details', target: 'blank')
          end
          row :id
          row :amount
          row(:status){|r| status_tag(r.payment_status)}
          row :debited_at
          row :created_at
        end
      end
    end
    column do
      panel 'Einzahlung in den Topf' do
        attributes_table_for crowd_boost_charge do
          row :crowd_boost
          row :region_id
        end
      end
      panel 'Charge Type' do
        attributes_table_for crowd_boost_charge do
          row :zuckerl
          row :room_booster
          row :subscription_invoice
          row :crowd_pledge
        end
      end
    end
  end

  if crowd_boost_charge.invoice_number?
    panel 'Beleg' do
      attributes_table_for crowd_boost_charge do
        row :invoice_number
        row(:invoice) { |r| link_to "PDF", r.invoice.presigned_url(:get) }
      end
    end
  end

  panel 'Kontaktdaten' do
    attributes_table_for crowd_boost_charge do
      row :contact_name
      row :email
      row :address_street
      row :address_zip
      row :address_city
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
