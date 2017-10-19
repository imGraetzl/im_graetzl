class FixRoomOfferCategories < ActiveRecord::Migration[5.0]
  def change
    rename_column :room_offer_categories, :room_demand_id, :room_offer_id
    remove_foreign_key :room_offer_categories, :room_demands
    add_foreign_key :room_offer_categories, :room_offers
  end
end
