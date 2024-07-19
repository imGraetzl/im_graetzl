context.instance_eval do
  selectable_column
  id_column
  column :user
  column(:status){|r| status_tag(r.status)}
  column :amount
  column :crowd_boost_charge_amount
  column :created_at
  actions
end
