class AddMeetingAdditionalDatesCountToMeetings < ActiveRecord::Migration[7.0]
  def change
    add_column :meetings, :meeting_additional_dates_count, :integer, default: 0, null: false
  end
end