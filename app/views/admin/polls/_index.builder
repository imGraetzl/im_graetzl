context.instance_eval do
  selectable_column
  id_column
  column :region_id
  column :poll_type
  column :title
  column(:status){|p| status_tag(p.status)}
  column(:teilnehmer) {|p| p.poll_users.size}
  column :last_activity_at
  actions
end
