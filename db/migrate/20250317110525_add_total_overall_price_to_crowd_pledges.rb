class AddTotalOverallPriceToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :total_overall_price, :decimal, precision: 10, scale: 2
  end
end
