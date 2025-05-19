context.instance_eval do
  selectable_column
  id_column
  column(:starts_at){ |z| z.runtime }
  column :title
  column(:aasm_state){ |z| status_tag(z.aasm.current_state) }
  column(:payment_status){|z| status_tag(z.payment_status)}
  column :visibility
  column :created_at
  actions
end
