class AddDefaultsToNotificationSettings < ActiveRecord::Migration
  def change
    change_column_default :users, :enabled_website_notifications, 999999
    change_column_default :users, :immediate_mail_notifications, 9999999
  end
end
