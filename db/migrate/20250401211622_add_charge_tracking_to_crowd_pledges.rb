class AddChargeTrackingToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :charge_returned_at, :datetime
    add_column :crowd_pledges, :charge_seen_at, :datetime
  end
end
