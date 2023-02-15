class AddLastActivatedAtToMeetings < ActiveRecord::Migration[6.1]
  def change
    add_column :meetings, :last_activated_at, :date
  end
end
