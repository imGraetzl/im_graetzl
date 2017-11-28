class RemoveRentsFromRoomOffer < ActiveRecord::Migration[5.0]
  def change
    remove_column :room_offers, :daily_rent, :boolean
    remove_column :room_offers, :longterm_rent, :boolean
    remove_column :room_demands, :daily_rent, :boolean
    remove_column :room_demands, :longterm_rent, :boolean
  end
end
