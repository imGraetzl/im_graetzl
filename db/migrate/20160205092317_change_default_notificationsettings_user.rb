class ChangeDefaultNotificationsettingsUser < ActiveRecord::Migration
  def up
    change_column :users, :enabled_website_notifications, :integer, default: 4088
    change_column :users, :immediate_mail_notifications, :integer, default: 4088
    change_column :users, :daily_mail_notifications, :integer, default: 7

    say_with_time 'Update notification_settings for users' do
      User.update_all(enabled_website_notifications: 4088,
                      immediate_mail_notifications: 4088,
                      daily_mail_notifications: 7)
    end
  end

  def down
    # nothing to do here...
  end
end
