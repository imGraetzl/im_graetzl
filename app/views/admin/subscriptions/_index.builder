context.instance_eval do
  id_column
  column :user
  column(:status){|r| status_tag(r.status)}
  column(:subscription_plan) {|p| p.subscription_plan.amount }
  column :region
  column :created_at
  actions
end
