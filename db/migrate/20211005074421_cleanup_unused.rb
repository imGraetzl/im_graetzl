class CleanupUnused < ActiveRecord::Migration[6.1]
  def change
    drop_table :addresses
    remove_column :notifications, :activity_id
    remove_column :activities, :key
    remove_column :activities, :owner_id
    remove_column :activities, :owner_type
  end
end
