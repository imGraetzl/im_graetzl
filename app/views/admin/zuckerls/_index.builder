context.instance_eval do
  selectable_column
  id_column
  column :title
  column(:aasm_state){ |z| status_tag(z.aasm.current_state) }
  column :paid_at
  column :flyer
  column :created_at
  actions
end
