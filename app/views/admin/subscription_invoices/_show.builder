context.instance_eval do
  attributes_table do
    row :id
    row(:status){|r| status_tag(r.status)}
    row :stripe_id
    row :stripe_payment_intent_id
    row :invoice_number
    row :invoice_pdf
    row(:invoice_pdf){|u| link_to 'Download Rechnung', u.generate_invoice_pdf }
    row :user
    row :created_at
    row :updated_at
    row :subscription
    row :amount
    row :crowd_boost_charge_amount
    row :crowd_boost
  end
end
