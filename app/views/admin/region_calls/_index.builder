context.instance_eval do
  selectable_column
  id_column
  column :region_type
  column :region_id
  column :gemeinden
  column :name
  column :personal_position
  column :email
  column :phone
  actions
end
