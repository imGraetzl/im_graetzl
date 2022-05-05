class AddAimToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :aim_description, :text
  end
end
