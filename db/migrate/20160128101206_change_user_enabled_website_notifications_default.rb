class ChangeUserEnabledWebsiteNotificationsDefault < ActiveRecord::Migration
  def up
    change_column_default :users, :enabled_website_notifications, from: 2047, to: 4095

    say_with_time 'Updating user enabled_website_notifications_bitmask' do
      User.find_each do |user|
        new_setting = user.enabled_website_notifications | 4095
        user.update_attribute(:enabled_website_notifications, new_setting)
      end
    end
  end

  def down
    change_column_default :users, :enabled_website_notifications, from: 4095, to: 2047

    say_with_time 'Reset user enabled_website_notifications_bitmask' do
      User.find_each do |user|
        new_setting = user.enabled_website_notifications ^ 2048
        user.update_attribute(:enabled_website_notifications, new_setting)
      end
    end
  end
end
