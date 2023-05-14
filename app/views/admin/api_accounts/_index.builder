context.instance_eval do
  selectable_column
  id_column
  column :name
  column :api_key
  column :enabled
  column :region_id
  actions
end
