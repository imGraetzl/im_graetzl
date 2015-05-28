class DropGraetzlMeetingsTable < ActiveRecord::Migration
  def change
    drop_table :graetzl_meetings
  end
end