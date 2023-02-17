context.instance_eval do
  selectable_column
  id_column
  column :title
  column(:aasm_state){ |z| status_tag(z.aasm.current_state) }
  column(:payment_status){|z| status_tag(z.payment_status)}
  column :invoice_number
  column(:district){|z| z.graetzl.district.zip}
  column :entire_region
  column :created_at
  actions
end
