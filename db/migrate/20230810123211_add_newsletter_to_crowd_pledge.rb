class AddNewsletterToCrowdPledge < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :guest_newsletter, :boolean, default: false, null: false
  end
end
