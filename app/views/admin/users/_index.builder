context.instance_eval do
  selectable_column
  id_column
  column :username
  column :email
  column :first_name
  column :last_name
  column :graetzl
  column :last_sign_in_at
  actions
end