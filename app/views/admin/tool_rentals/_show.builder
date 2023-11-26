context.instance_eval do
  panel 'Tool Offer' do
    attributes_table_for tool_rental do
      row :tool_offer
      row(:owner) { |r| r.owner }
      row(:iban) { |r| r.tool_offer.iban }
    end
  end

  panel 'Rent Request' do
    attributes_table_for tool_rental do
      row :id
      row :renter
      row(:rental_status){|r| status_tag(r.rental_status)}
      row :rent_from
      row :rent_to
      row :renter_company
      row :renter_name
      row :renter_address
      row :renter_zip
      row :renter_city
      row :created_at
    end
  end

  panel 'Payment' do
    attributes_table_for tool_rental do
      row :basic_price
      row :discount
      row :service_fee
      row :insurance_fee
      row :tax
      row :total_price
      row :owner_payout_amount
      row(:payment_status){|r| status_tag(r.payment_status)}
      row :payment_method
      row :debited_at
    end
  end

  if tool_rental.invoice_number?
    panel 'Invoices' do
      attributes_table_for tool_rental do
        row(:owner_invoice) { |r| link_to "PDF", r.owner_invoice.presigned_url(:get) }
        row(:renter_invoice) { |r| link_to "PDF", r.renter_invoice.presigned_url(:get) }
      end
    end
  end

  panel 'Stripe Informationen' do
    attributes_table_for tool_rental do
      row :stripe_payment_method_id
      row :stripe_payment_intent_id
      row :payment_method
      row :payment_card_last4
      row :payment_wallet
    end
  end

  panel 'Rating' do
    attributes_table_for tool_rental do
      row :owner_rating
      row :renter_rating
    end
  end

end
