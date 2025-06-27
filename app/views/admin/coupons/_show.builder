context.instance_eval do
  attributes_table do
    row :id
    row :region_id
    row :name
    row :description
    row :code
    row :stripe_id
    row :amount_off
    row :percent_off
    row :duration
    row :created_at
    row :valid_from
    row :valid_until
    row :enabled
    row(:coupon_histroy_count){|c| c.users.count}
    row(:coupon_histroy_sent_count){|c| c.coupon_histories.sent.count}
    row(:coupon_histroy_redeemed_count){|c| c.coupon_histories.redeemed.count}
    row(:subscriptions_active_count){|c| c.subscriptions.active.count}
  end
end
