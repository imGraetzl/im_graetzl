context.instance_eval do
  selectable_column
  column :total_price
  #column(:boost_charge){|b| b.crowd_boost_charge_amount}
  column :user
  column :email
  column(:status){|r| status_tag(r.status)}
  column :created_at
  column :payment_method
  column :debited_at
  column :crowd_campaign
  actions
end
