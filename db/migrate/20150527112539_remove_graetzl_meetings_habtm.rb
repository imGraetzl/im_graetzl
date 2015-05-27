class RemoveGraetzlMeetingsHabtm < ActiveRecord::Migration
  def change
    drop_table :graetzls_meetings
  end
end
