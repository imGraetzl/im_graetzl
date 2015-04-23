class ChangeDatetimeColumnsMeeting < ActiveRecord::Migration
  def change
    rename_column :meetings, :start, :starts_at
    rename_column :meetings, :end, :ends_at
  end
end
