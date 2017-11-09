class DropRoomDemandDistricts < ActiveRecord::Migration[5.0]
  def change
    drop_table :room_demand_districts
  end
end
