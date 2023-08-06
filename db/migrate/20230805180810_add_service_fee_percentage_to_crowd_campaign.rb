class AddServiceFeePercentageToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :service_fee_percentage, :decimal, precision: 5, scale: 2
  end
end
