class AddMeetingPermissionToLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :allow_meetings
    add_column :locations, :meeting_permission, :integer, default: 0, null: false
  end

  def down
    remove_column :locations, :meeting_permission
    add_column :locations, :allow_meetings, :boolean, null: false, default: true
  end
end
