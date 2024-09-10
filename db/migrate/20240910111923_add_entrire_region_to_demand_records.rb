class AddEntrireRegionToDemandRecords < ActiveRecord::Migration[6.1]
  def change

    add_column :coop_demands, :entire_region, :boolean, default: false, null: false
    add_column :room_demands, :entire_region, :boolean, default: false, null: false
    
  end
end
