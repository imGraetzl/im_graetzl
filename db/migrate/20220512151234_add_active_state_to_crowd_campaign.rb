class AddActiveStateToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :active_state, :integer, default: 0
  end
end
