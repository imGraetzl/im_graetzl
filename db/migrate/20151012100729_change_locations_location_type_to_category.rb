class ChangeLocationsLocationTypeToCategory < ActiveRecord::Migration
  def change
    remove_column :locations, :location_type
    add_column :locations, :category_id, :integer
  end
end
