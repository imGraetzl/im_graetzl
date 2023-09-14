class AddEntrireRedgionToMeetingsAndLocations < ActiveRecord::Migration[6.1]
  def change

    add_column :meetings, :entire_region, :boolean, default: false, null: false
    add_column :locations, :entire_region, :boolean, default: false, null: false

  end
end
