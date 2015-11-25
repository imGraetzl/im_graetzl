context.instance_eval do
  selectable_column
  id_column
  column :slug
  column :author
  column :graetzl
  column :created_at
  actions
end
