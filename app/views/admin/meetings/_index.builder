context.instance_eval do
  selectable_column
  id_column
  column :name
  column :graetzl
  column :user
  column :created_at
  column 'API', :approved_for_api
  column 'Region', :entire_region
  actions
end
