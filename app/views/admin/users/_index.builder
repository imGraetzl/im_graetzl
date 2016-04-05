context.instance_eval do
  selectable_column
  id_column
  column :username
  column :email
  column :graetzl
  column :last_sign_in_at
  actions
end
