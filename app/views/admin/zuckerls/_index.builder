context.instance_eval do
  selectable_column
  id_column
  column(:payment_reference){|z| z.payment_reference}
  column :title
  column(:aasm_state){ |z| status_tag(z.aasm.current_state) }
  column :paid_at
  column :entire_region
  column :created_at
  actions
end
