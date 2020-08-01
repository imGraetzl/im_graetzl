class CreateRoomRentalPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :room_rental_prices do |t|
      t.integer :room_offer_id
      t.string :name
      t.decimal :price_per_hour, precision: 10, scale: 2
      t.integer :minimum_rental_hours, default: 0
      t.integer :four_hour_discount, default: 0
      t.integer :eight_hour_discount, default: 0
      t.timestamps
    end
  end
end
