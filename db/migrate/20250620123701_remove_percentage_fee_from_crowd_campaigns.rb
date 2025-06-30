class RemovePercentageFeeFromCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:crowd_campaigns, :percentage_fee)
      remove_column :crowd_campaigns, :percentage_fee
    end
  end
end
