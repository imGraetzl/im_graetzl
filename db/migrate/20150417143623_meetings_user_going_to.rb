class MeetingsUserGoingTo < ActiveRecord::Migration
  def change
    create_table :meetings_users_going, id: false do |t|
      t.belongs_to :meeting, index: true
      t.belongs_to :user, index: true
    end
  end
end
