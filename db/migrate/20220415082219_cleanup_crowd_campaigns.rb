class CleanupCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    remove_column :crowd_campaigns, :runtime
    remove_column :crowd_donations, :limit
  end
end
