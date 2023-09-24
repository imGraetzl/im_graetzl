class AddIncompleteReminderSentAtToCrowdPledge < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :inclomplete_reminder_sent_at, :datetime
  end
end
