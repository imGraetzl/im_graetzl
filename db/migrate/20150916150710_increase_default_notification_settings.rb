class IncreaseDefaultNotificationSettings < ActiveRecord::Migration
  def change
    change_column_default :users, :enabled_website_notifications, 9999999
    change_column_default :users, :immediate_mail_notifications, 99999999
  end
end