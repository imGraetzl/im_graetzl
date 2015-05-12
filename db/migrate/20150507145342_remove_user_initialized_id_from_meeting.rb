class RemoveUserInitializedIdFromMeeting < ActiveRecord::Migration
  def change
    remove_index :meetings, :user_initialized_id
    remove_column :meetings, :user_initialized_id, :integer
  end
end
