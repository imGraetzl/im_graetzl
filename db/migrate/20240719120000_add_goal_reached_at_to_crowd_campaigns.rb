class AddGoalReachedAtToCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :goal_1_reached_at, :datetime
    add_column :crowd_campaigns, :goal_2_reached_at, :datetime
  end
end
