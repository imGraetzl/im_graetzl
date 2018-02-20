context.instance_eval do
  selectable_column
  id_column
  column :name
  column(:state){ |l| status_tag(l.state) }
  column :category
  column :graetzl
  column(:user) { |l| l.location_ownerships.first.try(:user_id)}
  actions
end
