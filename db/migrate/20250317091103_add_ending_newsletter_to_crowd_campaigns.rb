class AddEndingNewsletterToCrowdCampaigns < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :ending_newsletter, :boolean, default: false, null: false
  end
end
