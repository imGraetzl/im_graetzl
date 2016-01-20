class AddKeyToNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :key, :string

    say_with_time 'Updating existing notification records to have a key value' do
      Notification.destroy_all
    end

    change_column_null :notifications, :key, false
  end

  def down
    remove_column :notifications, :key, :string
  end
end
