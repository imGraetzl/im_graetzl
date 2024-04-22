context.instance_eval do
  selectable_column
  id_column
  column(:status){|b| status_tag(b.status)}
  column :title
  column(:balance){|b| b.balance}
  column :boost_amount
  column :boost_precentage
  column(:active_slots){|b| b.crowd_boost_slots.active.count}
  column(:charges){|b| b.crowd_boost_charges.debited.count}
  column(:pledges){|b| b.crowd_boost_pledges.debited.count}
  actions
end
