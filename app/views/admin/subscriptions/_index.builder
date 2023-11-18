context.instance_eval do
  id_column
  column :user
  column(:status){|r| status_tag(r.status)}
  column :subscription_plan
  column :coupon
  column :region
  column(:subscribed){|r| status_tag(r.user&.subscribed?)}
  column('Auslaufend'){|r| status_tag(r.on_grace_period?)}
  column :ends_at
  column :created_at
  actions
end
