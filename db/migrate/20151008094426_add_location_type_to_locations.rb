class AddLocationTypeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :location_type, :integer, default: 0, null: false
  end
end
