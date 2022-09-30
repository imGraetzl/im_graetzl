context.instance_eval do
  selectable_column
  id_column
  column :name
  column :amount
  column :interval
  column :stripe_id
  column :created_at
  actions
end
