context.instance_eval do
  selectable_column
  id_column
  column :title
  column :location
  column :graetzl
  column :created_at
  actions
end
