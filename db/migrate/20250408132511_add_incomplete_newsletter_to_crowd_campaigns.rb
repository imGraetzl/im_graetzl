class AddIncompleteNewsletterToCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :incomplete_newsletter, :boolean, default: false, null: false
  end
end