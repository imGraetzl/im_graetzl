context.instance_eval do
  selectable_column
  id_column
  column :name
  column :code
  column :region_id
  column :duration
  column :amount_off
  column :percent_off
  column :enabled
  actions
end
