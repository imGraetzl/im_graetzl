context.instance_eval do
  selectable_column
  column :total_price
  column :email
  column(:status){|r| status_tag(r.status)}
  column :created_at
  column :debited_at
  column :crowd_campaign
  actions
end
