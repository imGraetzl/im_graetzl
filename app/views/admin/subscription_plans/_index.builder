context.instance_eval do
  selectable_column
  id_column
  column :region_id
  column :name
  column :amount
  column :coupon
  column :interval
  column :stripe_id
  column :created_at
  actions
end
