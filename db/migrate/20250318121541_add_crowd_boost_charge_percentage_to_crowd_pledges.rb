class AddCrowdBoostChargePercentageToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :crowd_boost_charge_percentage, :decimal, precision: 5, scale: 2
  end
end
