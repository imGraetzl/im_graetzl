class AddAvatarToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :avatar_data, :jsonb
  end
end
