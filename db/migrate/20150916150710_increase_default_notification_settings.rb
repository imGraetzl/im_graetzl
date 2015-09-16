class IncreaseDefaultNotificationSettings < ActiveRecord::Migration
  def up
    change_column_default :users, :enabled_website_notifications, 9999999
    change_column_default :users, :immediate_mail_notifications, 99999999

    # just reset the settings for now
    User.find_each do |user|
      user.enabled_website_notifications = 9999999
      user.immediate_mail_notifications = 99999999
      user.save!
    end
  end

  def down
    change_column_default :users, :enabled_website_notifications, 999999
    change_column_default :users, :immediate_mail_notifications, 9999999
  end
end