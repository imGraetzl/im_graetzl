class AddMailNotificationSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :immediate_mail_notifications, :integer, :default => 0
    add_column :users, :daily_mail_notifications, :integer, :default => 0
    add_column :users, :weekly_mail_notifications, :integer, :default => 0
  end
end
