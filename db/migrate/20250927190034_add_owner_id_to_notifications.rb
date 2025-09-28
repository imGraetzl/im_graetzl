class AddOwnerIdToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :owner_id, :integer
    add_index :notifications, :owner_id
  end
end
