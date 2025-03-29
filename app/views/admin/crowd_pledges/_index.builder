context.instance_eval do
  selectable_column
  column 'Total', :total_price
  column 'Charge', :crowd_boost_charge_amount
  column :user
  column :email
  column(:status){|r| status_tag(r.status)}
  column :created_at
  column 'Payment', :payment_method
  column :debited_at
  column :crowd_campaign
  actions
end
