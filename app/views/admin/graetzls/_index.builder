context.instance_eval do
  selectable_column
  id_column
  column :name
  column :slug
  column :users_count
  actions
end
