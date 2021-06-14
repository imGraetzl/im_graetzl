class AddSlugToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :room_categories, :slug, :string
    add_index :room_categories, :slug, unique: true

    add_column :tool_categories, :slug, :string
    add_index :tool_categories, :slug, unique: true

    add_column :event_categories, :slug, :string
    add_index :event_categories, :slug, unique: true
  
    add_column :location_categories, :slug, :string
    add_index :location_categories, :slug, unique: true
  end
end
