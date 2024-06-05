context.instance_eval do
  selectable_column
  column :amount
  column :email
  column(:payment_status){|r| status_tag(r.payment_status)}
  column :created_at
  column :payment_method
  column :debited_at
  column :crowd_boost
  column(:invoice) { |z| link_to "Zahlungsbeleg", z.invoice.presigned_url(:get) if z.invoice_number.present? }
  actions
end
