class RenameRoomDemandMainImage < ActiveRecord::Migration[5.0]
  def change
    rename_column :room_offers, :main_image_id, :cover_photo_id
    rename_column :room_offers, :main_image_content_type, :cover_photo_content_type
  end
end
