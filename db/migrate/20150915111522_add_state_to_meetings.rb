class AddStateToMeetings < ActiveRecord::Migration
  def change
     add_column :meetings, :state, :integer, default: 0
  end
end
