class AddSocialLinksToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :contact_instagram, :string
    add_column :crowd_campaigns, :contact_facebook, :string
  end
end
