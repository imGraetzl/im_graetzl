class RenameCoverPhotoField < ActiveRecord::Migration
  def change
    remove_column :meetings, :cover_photo, :string
    add_column :meetings, :cover_photo_id, :string
  end
end
