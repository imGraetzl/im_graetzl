context.instance_eval do
  selectable_column
  id_column
  column :region
  column :title
  column :user
  column(:status){|r| status_tag(r.status)}
  actions
end
