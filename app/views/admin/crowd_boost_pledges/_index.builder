context.instance_eval do
  selectable_column
  column :amount
  column(:status){|r| status_tag(r.status)}
  column :created_at
  column :crowd_campaign
  column :crowd_boost
  column :crowd_boost_slot
  actions
end
