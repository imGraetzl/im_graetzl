class DropCampaignUsersTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :campaign_users
  end
end
