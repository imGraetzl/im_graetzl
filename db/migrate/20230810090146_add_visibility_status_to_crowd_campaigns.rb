class AddVisibilityStatusToCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :visibility_status, :string
  end
end
