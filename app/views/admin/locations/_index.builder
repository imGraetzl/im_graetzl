context.instance_eval do
  selectable_column
  id_column
  column :name
  column(:state){ |l| status_tag(l.state) }
  column :category
  column :slug
  column :graetzl
  column :updated_at
  actions
end
