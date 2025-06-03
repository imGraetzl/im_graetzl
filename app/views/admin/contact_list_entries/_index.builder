context.instance_eval do
  selectable_column
  id_column
  column :via_path
  column :region_id
  column :name
  column :email
  column :phone
  column :user
  column :created_at
  actions
end
