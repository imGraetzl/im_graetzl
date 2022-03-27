class AddFundingStatusToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :funding_status, :integer, default: 0
  end
end
