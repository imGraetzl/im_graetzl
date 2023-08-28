class AddVerifiedToLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :verified, :boolean, default: false, null: false
  end
end
