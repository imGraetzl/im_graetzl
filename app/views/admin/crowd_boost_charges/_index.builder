context.instance_eval do
  selectable_column
  column :amount
  column :email
  column(:payment_status){|r| status_tag(r.payment_status)}
  column :created_at
  column :payment_method
  column :debited_at
  column :crowd_boost
  actions
end
