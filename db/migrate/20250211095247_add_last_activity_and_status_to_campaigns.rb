class AddLastActivityAndStatusToCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :last_activity_at, :datetime
    add_column :crowd_campaigns, :payout_attempted_at, :datetime
    add_column :crowd_campaigns, :payout_completed_at, :datetime
    add_column :crowd_campaigns, :transfer_status, :string
    add_column :crowd_campaigns, :stripe_payout_transfer_id, :string

    add_index :crowd_campaigns, :last_activity_at
  end
end
