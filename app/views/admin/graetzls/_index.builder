context.instance_eval do
  selectable_column
  id_column
  column :name
  column :slug
  column('#Users'){ |g| g.users.count }
  actions
end
