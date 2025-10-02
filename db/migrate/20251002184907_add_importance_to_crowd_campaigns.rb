class AddImportanceToCrowdCampaigns < ActiveRecord::Migration[7.2]
  def change
    add_column :crowd_campaigns, :importance, :integer, default: 1, null: false
  end
end
