class AddAuthorizedAtToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :authorized_at, :datetime
  end
end
