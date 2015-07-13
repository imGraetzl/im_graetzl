class RemoveWebsiteNotificationsLastCheckedFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :website_notifications_last_checked
  end
end
