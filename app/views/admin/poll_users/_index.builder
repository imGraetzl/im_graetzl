context.instance_eval do
  selectable_column
  id_column
  column :poll
  column :user
  column :created_at
  actions
end
