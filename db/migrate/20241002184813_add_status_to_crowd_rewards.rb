class AddStatusToCrowdRewards < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_rewards, :status, :integer, default: 0
  end
end
