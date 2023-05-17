context.instance_eval do
  selectable_column
  id_column
  column :poll_type
  column :title
  column(:status){|r| status_tag(r.status)}
  column :created_at
  actions
end
