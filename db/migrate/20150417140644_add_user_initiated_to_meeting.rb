class AddUserInitiatedToMeeting < ActiveRecord::Migration
  def change
    add_reference :meetings, :user_initialized, references: :users, index: true
  end
end
