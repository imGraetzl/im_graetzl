context.instance_eval do
  selectable_column
  id_column
  column :region
  column :title
  column :user
  column(:status){|r| status_tag(r.status)}
  column(:funding_status){|r| status_tag(r.funding_status)}
  actions
end
