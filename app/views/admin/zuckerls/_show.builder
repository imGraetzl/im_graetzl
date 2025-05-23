context.instance_eval do
  attributes_table do
    row :id
    row :user
    row :location
    row :subscription
    row :created_at
    row :starts_at
    row :ends_at
    row(:aasm_state){|z| status_tag(z.aasm_state)}
    row :amount
    row(:payment_status){|z| status_tag(z.payment_status)}
    row :debited_at
    row :invoice_number
    if zuckerl.invoice_number.present?
      row(:zuckerl_invoice) { |z| link_to "PDF Rechnung", z.zuckerl_invoice.presigned_url(:get) }
    end
    row :entire_region
    row :visibility
    row :title
    row :description
    row :link
    row :cover_photo do |z|
      z.cover_photo && image_tag(z.cover_photo_url(:thumb))
    end
    row :graetzls do |z|
      z.graetzls.map(&:name).join(', ')
    end
  end

  panel 'CrowdBoostCharge' do
    attributes_table_for zuckerl do
      row :crowd_boost
      row :crowd_boost_charge_amount
      row :crowd_boost_charge
    end
  end

  panel 'Rechnungsadresse' do
    attributes_table_for zuckerl do
      row :company
      row :name
      row :address
      row :zip
      row :city
    end
  end

  panel 'Stripe Informationen' do
    attributes_table_for zuckerl do
      row :stripe_payment_method_id
      row :stripe_payment_intent_id
      row :payment_method
      row :payment_card_last4
      row :payment_wallet
    end
  end

end
