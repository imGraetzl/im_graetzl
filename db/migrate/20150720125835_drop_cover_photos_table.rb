class DropCoverPhotosTable < ActiveRecord::Migration
  def change
    drop_table :cover_photos
  end
end
