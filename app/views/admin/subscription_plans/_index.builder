context.instance_eval do
  selectable_column
  id_column
  column :region_id
  column :name
  column(:status){|r| status_tag(r.status)}
  column :amount
  column :interval
  column :stripe_id
  column :created_at
  actions
end
