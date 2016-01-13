class RemoveKeyFromNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :key, :string, null: false
  end
end
