class AddDisputeStatusToCrowdPledges < ActiveRecord::Migration[7.2]
  def change
    add_column :crowd_pledges, :dispute_status, :string
  end
end
