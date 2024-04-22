context.instance_eval do
  selectable_column
  id_column
  column(:active){|b| b.active?}
  column(:crowd_boost){|b| b.crowd_boost}
  column :starts_at
  column :ends_at
  column :amount_limit
  column(:balance){|b| b.balance}
  column(:pledges){|b| b.crowd_boost_pledges.count}
  column(:campaigns){|b| b.crowd_campaigns.count}
  actions
end
