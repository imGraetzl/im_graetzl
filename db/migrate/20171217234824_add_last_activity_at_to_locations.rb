class AddLastActivityAtToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :last_activity_at, :datetime
    add_index :locations, :last_activity_at
  end
end
