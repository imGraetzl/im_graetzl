context.instance_eval do
  selectable_column
  id_column
  column :position
  column :title
  column :hidden
  column :created_at
  actions
end
