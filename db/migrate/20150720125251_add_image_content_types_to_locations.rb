class AddImageContentTypesToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :avatar_content_type, :string
    add_column :locations, :cover_photo_content_type, :string
  end
end
