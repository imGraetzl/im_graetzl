class AddNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :user
      t.belongs_to :activity
      t.integer :bitmask, null: false
      t.boolean :seen, default: false
      t.timestamps
    end
  end
end
