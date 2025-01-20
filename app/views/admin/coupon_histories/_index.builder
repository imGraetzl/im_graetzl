context.instance_eval do
  selectable_column
  id_column
  column :user
  column :coupon
  column :stripe_id
  column :sent_at
  column :redeemed_at
  column :created_at
  actions
end
