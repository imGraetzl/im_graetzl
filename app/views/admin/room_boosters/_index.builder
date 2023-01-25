context.instance_eval do
  selectable_column
  id_column
  column(:status){ |z| status_tag(z.status) }
  column(:payment_status){|z| status_tag(z.payment_status)}
  column :invoice_number
  column :send_at_date
  column :created_at
  column(:invoice) { |z| link_to "PDF Rechnung", z.invoice.presigned_url(:get) if z.invoice_number.present? }
  actions
end
