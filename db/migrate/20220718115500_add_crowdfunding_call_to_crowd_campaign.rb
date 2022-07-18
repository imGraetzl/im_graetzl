class AddCrowdfundingCallToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :crowdfunding_call, :boolean, default: false
  end
end
