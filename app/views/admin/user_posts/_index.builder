context.instance_eval do
  selectable_column
  id_column
  column :title
  column :author
  column :graetzl
  column :created_at
  actions
end
