context.instance_eval do
  selectable_column
  id_column
  column :name
  column(:state){ |m| status_tag(m.state) }
  column :slug
  column :graetzl
  column :initiator
  column :location
  column :updated_at
  actions
end