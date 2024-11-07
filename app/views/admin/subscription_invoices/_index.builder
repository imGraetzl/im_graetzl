context.instance_eval do
  selectable_column
  id_column
  column :user
  column(:status){|r| status_tag(r.status)}
  column :amount
  column :debited_at
  column :created_at
  actions
end
