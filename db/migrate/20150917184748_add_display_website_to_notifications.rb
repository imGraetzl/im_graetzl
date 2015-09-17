class AddDisplayWebsiteToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :display_on_website, :boolean, :default => false
  end
end
