class DropRoomModulesTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :room_modules
  end
end
