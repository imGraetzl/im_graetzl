context.instance_eval do
  selectable_column
  id_column
  column :name
  column(:state){ |l| status_tag(l.state) }
  column :location_category
  column :region
  column :graetzl
  actions
end
