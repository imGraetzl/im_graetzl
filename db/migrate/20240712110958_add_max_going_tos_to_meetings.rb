class AddMaxGoingTosToMeetings < ActiveRecord::Migration[6.1]
  def change
    add_column :meetings, :max_going_tos, :integer
  end
end
