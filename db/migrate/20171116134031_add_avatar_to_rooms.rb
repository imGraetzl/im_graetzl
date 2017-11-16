class AddAvatarToRooms < ActiveRecord::Migration[5.0]
  def change
    change_table :room_offers do |t|
      t.string :avatar_id
      t.string :avatar_content_type
    end

    change_table :room_demands do |t|
      t.string :avatar_id
      t.string :avatar_content_type
    end
  end
end
