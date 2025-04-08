class AddDisputedAtToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :disputed_at, :datetime
  end
end