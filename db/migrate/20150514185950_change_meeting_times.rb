class ChangeMeetingTimes < ActiveRecord::Migration
  def change
    change_table :meetings do |t|
      t.remove :starts_at
      t.remove :ends_at
      t.date :starts_at_date
      t.date :ends_at_date
      t.time :starts_at_time
      t.time :ends_at_time
    end
  end
end
