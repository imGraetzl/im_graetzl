class ChangeUserImmediateMailNotifications < ActiveRecord::Migration
  def up
    change_column_default :users, :immediate_mail_notifications, from: 2013, to: 4088

    say_with_time 'Updating user immediate_mail_notifications_bitmask' do
      User.update_all(immediate_mail_notifications: 4088)
    end
  end

  def down
    change_column_default :users, :immediate_mail_notifications, from: 4088, to: 2013

    say_with_time 'Reset user immediate_mail_notifications_bitmask' do
      User.update_all(immediate_mail_notifications: 2013)
    end
  end
end
