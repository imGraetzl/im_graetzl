class AddClaimedToCrowdRewards < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_rewards, :claimed, :integer, default: 0
    add_column :crowd_donations, :claimed, :integer, default: 0
  end
end
