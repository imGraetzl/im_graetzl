class RenameInclompleteReminderSentAtOnCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    rename_column :crowd_pledges, :inclomplete_reminder_sent_at, :incomplete_reminder_sent_at
  end
end
