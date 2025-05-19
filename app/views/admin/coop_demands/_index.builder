context.instance_eval do
  selectable_column
  id_column
  column :region
  column :slogan
  column :user
  column(:status){|r| status_tag(r.status)}
  column :last_activated_at
  actions
end
