class AddStartAtDateToRoomBoosters < ActiveRecord::Migration[6.1]
  def change
    add_column :room_boosters, :starts_at_date, :date
    add_column :room_boosters, :ends_at_date, :date
  end
end
