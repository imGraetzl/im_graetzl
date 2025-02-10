class AddIndexesToMeetings < ActiveRecord::Migration[6.1]
  def change
    # Index für Meetings starts_at_date (um Datums-Filter zu beschleunigen)
    add_index :meetings, :starts_at_date, name: "idx_meetings_starts_at_date"

    # Index für MeetingAdditionalDates starts_at_date (für zusätzlichen Datumsfilter)
    add_index :meeting_additional_dates, :starts_at_date, name: "idx_meeting_additional_dates_starts_at_date"

    # Kombinierter Index für bessere LEFT JOIN Performance
    add_index :meeting_additional_dates, [:meeting_id, :starts_at_date], name: "idx_meeting_additional_dates_meeting_id_starts_at_date"
  end
end
