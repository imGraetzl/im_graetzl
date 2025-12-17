context.instance_eval do
  selectable_column
  id_column
  column :via_path
  #column :region_id
  column :title
  column :url
  column :created_at
  column :name
  actions
end
