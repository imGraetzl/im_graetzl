context.instance_eval do
  selectable_column
  id_column
  column :regions do |b|
    safe_join(
      b.region_ids.map do |region|
        content_tag(:span, Region.get(region)) + ', '
      end
    )
  end
  column(:status){|b| status_tag(b.status)}
  #column('Chargeable'){|b| status_tag(b.chargeable_status)}
  #column(:active_slots){|b| b.crowd_boost_slots.active.count}
  #column(:open_slots){|b| b.crowd_boost_slots.open.count}
  column(:round_up){|b| b.pledge_charge}
  column :title
  column :balance
  column :balance_expected
  column(:charges){|b| b.crowd_boost_charges.debited.count}
  column(:charges_expected){|b| b.crowd_boost_charges.authorized.count}
  column(:charges_expected_sum){|b| b.crowd_boost_charges.authorized.sum(:amount)}
  column('Pledges'){|b| b.crowd_boost_pledges.debited.count}
  #actions
end
