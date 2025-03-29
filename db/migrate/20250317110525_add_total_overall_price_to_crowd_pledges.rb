class AddTotalOverallPriceToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :total_overall_price, :decimal, precision: 10, scale: 2
    add_column :crowd_pledges, :stripe_fee, :decimal, precision: 10, scale: 2
    add_column :crowd_pledges, :confirmation_sent_at, :datetime
    add_column :crowd_boosts, :pledge_charge, :boolean, default: false, null: false
  end
end
