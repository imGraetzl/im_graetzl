class AddFieldsToLocationCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :location_categories, :main_photo_id, :string
    add_column :location_categories, :main_photo_content_type, :string
    add_column :location_categories, :position, :integer, default: 0

    add_column :contacts, :online_shop, :string
  end
end
