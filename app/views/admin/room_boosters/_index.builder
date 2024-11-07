context.instance_eval do
  selectable_column
  id_column
  column(:status){ |z| status_tag(z.status) }
  column(:payment_status){|z| status_tag(z.payment_status)}
  column :room_offer
  column :user
  column :starts_at_date
  column :ends_at_date
  column(:invoice) { |z| link_to "PDF Rechnung", z.invoice.presigned_url(:get) if z.invoice_number.present? }
  actions
end
