class AddGuestNewsletterToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :guest_newsletter, :boolean, default: true, null: false
  end
end
