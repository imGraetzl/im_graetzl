class ChangeMailSettingsDefault < ActiveRecord::Migration
  def up
    User.find_each do |u|
      u.disable_mail_notification(:new_post_in_graetzl, :immediate)
    end
    change_column_default :users, :immediate_mail_notifications, 2013
  end

  def down
    change_column_default :users, :immediate_mail_notifications, 2015
  end
end