class AddAllowMeetingsToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :allow_meetings, :boolean, null: false, default: true
  end
end
