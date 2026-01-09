class AddBoostWaitlistedAtToCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :boost_waitlisted_at, :datetime
  end
end
