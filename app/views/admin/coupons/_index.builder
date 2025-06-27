context.instance_eval do
  selectable_column
  id_column
  column :name
  column :code
  column :region_id
  column :duration
  column :amount_off
  column :percent_off
  column(:valid?){|c| status_tag(c.valid_in_system?)}
  column("Sent", sortable: 'sent_count') do |c|
    c.attributes["sent_count"] || 0
  end

  column("Used", sortable: 'redeemed_count') do |c|
    c.attributes["redeemed_count"] || 0
  end
  actions
end
