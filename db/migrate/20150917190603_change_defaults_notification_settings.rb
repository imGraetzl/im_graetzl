class ChangeDefaultsNotificationSettings < ActiveRecord::Migration
  def change
    all_on = Notification::TYPES.keys.inject(0) { |sum, k| Notification::TYPES[k][:bitmask] | sum }
    change_column_default :users, :enabled_website_notifications, all_on
    change_column_default :users, :immediate_mail_notifications, all_on ^ Notification::TYPES[:another_user_comments][:bitmask]
    change_column_default :users, :daily_mail_notifications, Notification::TYPES[:another_user_comments][:bitmask]
  end
end
