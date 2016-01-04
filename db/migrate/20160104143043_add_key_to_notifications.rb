class AddKeyToNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :key, :string

    say_with_time 'Updating existing notification records to have a key value' do
      Notification.find_each do |n|
        key = Notification::TYPES.select{|k,v| v[:bitmask] == n.bitmask}.first[0]
        n.update(key: key)
      end
    end

    change_column_null :notifications, :key, false
  end

  def down
    remove_column :notifications, :key, :string
  end
end
