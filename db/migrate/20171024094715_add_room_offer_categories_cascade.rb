class AddRoomOfferCategoriesCascade < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :room_offer_categories, :room_offers
    add_foreign_key :room_offer_categories, :room_offers, on_delete: :cascade
    remove_foreign_key :room_offer_prices, :room_offers
    add_foreign_key :room_offer_prices, :room_offers, on_delete: :cascade
  end
end
