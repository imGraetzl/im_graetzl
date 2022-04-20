class AddFieldsToLocation < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :description_background, :text
    add_column :locations, :description_favorite_place, :text
  end
end
