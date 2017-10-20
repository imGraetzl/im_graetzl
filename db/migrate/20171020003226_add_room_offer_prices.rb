class AddRoomOfferPrices < ActiveRecord::Migration[5.0]
  def change
    create_table :room_offer_prices do |t|
      t.belongs_to :room_offer, foreign_key: true, index: true
      t.string :name
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end
  end
end
