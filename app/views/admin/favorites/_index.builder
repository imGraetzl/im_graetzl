context.instance_eval do
  selectable_column
  id_column
  column :user
  column :favoritable_type
  column :favoritable
  column :created_at
  actions
end
