class ChangeDefaultDailyMailNotificationsUsers < ActiveRecord::Migration
  def up
    change_column :users, :daily_mail_notifications, :integer, default: 0

    say_with_time 'Updating default daily_mail_notification settings to 0' do
      User.find_each do |u|
        u.update(daily_mail_notifications: 0)
      end
    end
  end

  def down
    change_column :users, :daily_mail_notifications, :integer, default: 32    

    say_with_time 'Updating default daily_mail_notification settings to 32' do
      User.find_each do |u|
        u.update(daily_mail_notifications: 32)
      end
    end
  end
end
