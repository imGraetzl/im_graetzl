class RemoveOldNotifications < ActiveRecord::Migration
  def up
    say_with_time 'Remove existing notification records without type value' do
      Notification.destroy_all
    end
  end

  def down
    # nothing to do here
  end
end
