context.instance_eval do
  selectable_column
  id_column
  column(:status){|b| status_tag(b.status)}
  column('Chargeable'){|b| status_tag(b.chargeable_status)}
  column :title
  column(:balance){|b| b.balance}
  column(:active_slots){|b| b.crowd_boost_slots.active.count}
  column(:open_slots){|b| b.crowd_boost_slots.open.count}
  column(:charges){|b| b.crowd_boost_charges.debited.count}
  column(:pledges){|b| b.crowd_boost_pledges.debited.count}
  actions
end
