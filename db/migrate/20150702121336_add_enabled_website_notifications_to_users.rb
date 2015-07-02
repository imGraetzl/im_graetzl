class AddEnabledWebsiteNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enabled_website_notifications, :integer, :default => 0
  end
end
