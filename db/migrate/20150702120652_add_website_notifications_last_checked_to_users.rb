class AddWebsiteNotificationsLastCheckedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :website_notifications_last_checked, :datetime
  end
end
