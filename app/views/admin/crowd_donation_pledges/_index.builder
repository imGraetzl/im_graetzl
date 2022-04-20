context.instance_eval do
  selectable_column
  column :crowd_donation
  column(:donation_type){|r| status_tag(r.donation_type)}
  column :email
  column :created_at
  column :crowd_campaign
  actions
end
