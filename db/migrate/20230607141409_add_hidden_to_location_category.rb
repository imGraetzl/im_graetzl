class AddHiddenToLocationCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :location_categories, :hidden, :boolean, default: false
  end
end
