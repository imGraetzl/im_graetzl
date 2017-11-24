class AddCascadeToForeignKeys < ActiveRecord::Migration[5.0]

  def change
    remove_foreign_key :district_graetzls, :districts
    add_foreign_key :district_graetzls, :districts, on_delete: :cascade

    remove_foreign_key :district_graetzls, :graetzls
    add_foreign_key :district_graetzls, :graetzls, on_delete: :cascade

    remove_foreign_key :room_demand_categories, :room_categories
    add_foreign_key :room_demand_categories, :room_categories, on_delete: :cascade

    remove_foreign_key :room_demand_categories, :room_demands
    add_foreign_key :room_demand_categories, :room_demands, on_delete: :cascade

    remove_foreign_key :room_demand_graetzls, :graetzls
    add_foreign_key :room_demand_graetzls, :graetzls, on_delete: :cascade

    remove_foreign_key :room_demand_graetzls, :room_demands
    add_foreign_key :room_demand_graetzls, :room_demands, on_delete: :cascade

    remove_foreign_key :room_demands, :locations
    add_foreign_key :room_demands, :locations, on_delete: :nullify

    remove_foreign_key :room_demands, :users
    add_foreign_key :room_demands, :users, on_delete: :cascade

    remove_foreign_key :room_offer_categories, :room_categories
    add_foreign_key :room_offer_categories, :room_categories, on_delete: :cascade

    remove_foreign_key :room_offers, :districts
    add_foreign_key :room_offers, :districts, on_delete: :nullify

    remove_foreign_key :room_offers, :graetzls
    add_foreign_key :room_offers, :graetzls, on_delete: :nullify

    remove_foreign_key :room_offers, :locations
    add_foreign_key :room_offers, :locations, on_delete: :nullify

    remove_foreign_key :room_offers, :users
    add_foreign_key :room_offers, :users, on_delete: :cascade
  end
end
