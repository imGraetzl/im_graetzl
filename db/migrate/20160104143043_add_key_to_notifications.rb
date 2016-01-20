class AddKeyToNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :key, :string

    change_column_null :notifications, :key, false
  end

  def down
    remove_column :notifications, :key, :string
  end
end
