class AddCrowdDonationPledgesCountToCrowdCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :crowd_campaigns, :crowd_donation_pledges_count, :integer, default: 0, null: false
  end
end