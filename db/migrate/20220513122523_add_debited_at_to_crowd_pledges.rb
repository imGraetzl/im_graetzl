class AddDebitedAtToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :debited_at, :datetime
  end
end
