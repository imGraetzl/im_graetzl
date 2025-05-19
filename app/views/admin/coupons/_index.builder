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
  column(:sent)     { |c| assigns[:sent_counts][c.id] || 0 }
  column(:redeemed) { |c| assigns[:redeemed_counts][c.id] || 0 }
  actions
end
