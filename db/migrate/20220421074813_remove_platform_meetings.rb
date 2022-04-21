class RemovePlatformMeetings < ActiveRecord::Migration[6.1]
  def change
    remove_column :meetings, :platform_meeting
    remove_column :meetings, :meeting_category_id
    drop_table :platform_meeting_join_requests
    drop_table :meeting_categories
  end
end
