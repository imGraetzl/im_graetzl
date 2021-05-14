class AddShrineColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :event_categories, :main_photo_data, :jsonb
    add_column :groups, :cover_photo_data, :jsonb
    add_column :images, :file_data, :jsonb
    add_column :locations, :avatar_data, :jsonb
    add_column :locations, :cover_photo_data, :jsonb
    add_column :location_categories, :main_photo_data, :jsonb
    add_column :meetings, :cover_photo_data, :jsonb
    add_column :room_calls, :cover_photo_data, :jsonb
    add_column :room_calls, :avatar_data, :jsonb
    add_column :room_categories, :main_photo_data, :jsonb
    add_column :room_demands, :avatar_data, :jsonb
    add_column :room_offers, :cover_photo_data, :jsonb
    add_column :room_offers, :avatar_data, :jsonb
    add_column :tool_categories, :main_photo_data, :jsonb
    add_column :tool_offers, :cover_photo_data, :jsonb
    add_column :users, :avatar_data, :jsonb
    add_column :users, :cover_photo_data, :jsonb
    add_column :zuckerls, :image_data, :jsonb
  end
end
