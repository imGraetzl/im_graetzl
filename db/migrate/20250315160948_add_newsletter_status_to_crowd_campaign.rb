class AddNewsletterStatusToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :newsletter_status, :string, default: "region", null: false
  end
end
