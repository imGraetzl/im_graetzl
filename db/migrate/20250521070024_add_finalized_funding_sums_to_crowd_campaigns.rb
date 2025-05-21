class AddFinalizedFundingSumsToCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :crowd_pledges_finalized_sum, :decimal, precision: 10, scale: 2
    add_column :crowd_campaigns, :crowd_boost_pledges_finalized_sum, :decimal, precision: 10, scale: 2
    add_column :crowd_campaigns, :pledges_and_donations_finalized_count, :integer
  end
end
