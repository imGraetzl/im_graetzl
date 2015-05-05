class DropMeetingsUsersGoingTable < ActiveRecord::Migration
  def change
    drop_table :meetings_users_going
  end
end
