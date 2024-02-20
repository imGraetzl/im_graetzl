class AddEegs < ActiveRecord::Migration[6.1]
  def change

    create_table :energy_offers do |t|
      t.integer "status", default: 0
      t.string :slug
      t.string "energy_type"
      t.string "operation_state"
      t.string "organization_form"
      t.string "title"
      t.text "description"
      t.text "project_goals"
      t.text "special_orientation"
      t.string "members_count"
      t.decimal "price_per_kwh", precision: 10, scale: 2

      t.boolean "goal_producer_solarpower", default: false
      t.boolean "goal_prosumer_solarpower", default: false
      t.boolean "goal_producer_windpower", default: false
      t.boolean "goal_prosumer_windpower", default: false
      t.boolean "goal_producer_hydropower", default: false
      t.boolean "goal_prosumer_hydropower", default: false
      t.boolean "goal_roofspace", default: false
      t.boolean "goal_freespace", default: false
      t.string "goal_producer_solarpower_kwp"
      t.string "goal_prosumer_solarpower_kwp"
      t.string "goal_roofspace_m2"
      t.string "goal_roofspace_direction"
      t.string "goal_freespace_m2"

      t.string "region_id"
      t.date "last_activated_at"
      t.jsonb "cover_photo_data"
      t.jsonb "avatar_data"

      t.string "contact_company"
      t.string "contact_name"
      t.string "contact_address"
      t.string "contact_zip"
      t.string "contact_city"
      t.string "contact_website"
      t.string "contact_email"
      t.string "contact_phone"

      t.timestamps
      t.index ["slug"], name: "index_energy_offers_on_slug"
      t.references :location, foreign_key: { on_delete: :nullify }, index: true
      t.references :user, foreign_key: { on_delete: :cascade }, index: true
    end

    create_table :energy_demands do |t|
      t.integer "status", default: 0
      t.string :slug
      t.string "energy_type"
      t.string "organization_form"
      t.string "title"
      t.text "description"

      t.boolean "goal_producer_solarpower", default: false
      t.boolean "goal_prosumer_solarpower", default: false
      t.boolean "goal_producer_windpower", default: false
      t.boolean "goal_prosumer_windpower", default: false
      t.boolean "goal_producer_hydropower", default: false
      t.boolean "goal_prosumer_hydropower", default: false
      t.boolean "goal_roofspace", default: false
      t.boolean "goal_freespace", default: false
      t.string "goal_producer_solarpower_kwp"
      t.string "goal_prosumer_solarpower_kwp"
      t.string "goal_roofspace_m2"
      t.string "goal_roofspace_direction"
      t.string "goal_freespace_m2"

      t.string "region_id"
      t.date "last_activated_at"
      t.jsonb "avatar_data"

      t.timestamps
      t.index ["slug"], name: "index_energy_demands_on_slug"
      t.references :user, foreign_key: { on_delete: :cascade }, index: true
    end

    create_table :energy_categories do |t|
      t.string :title
      t.string :label
      t.string :group
      t.string :css_ico_class
      t.jsonb :main_photo_data
      t.string :slug
      t.integer :position, default: 99
      t.boolean :hidden, default: false
      t.timestamps
      t.index ["slug"], name: "index_energy_categories_on_slug"
    end

    create_table :energy_offer_categories do |t|
      t.references :energy_offer, foreign_key: { on_delete: :cascade }, index: true
      t.references :energy_category, foreign_key: { on_delete: :cascade }, index: true
    end

    create_table :energy_demand_categories do |t|
      t.references :energy_demand, foreign_key: { on_delete: :cascade }, index: true
      t.references :energy_category, foreign_key: { on_delete: :cascade }, index: true
    end

    create_table :energy_offer_graetzls do |t|
      t.references :energy_offer, foreign_key: { on_delete: :cascade }, index: true
      t.references :graetzl, foreign_key: { on_delete: :cascade }, index: true
    end

    create_table :energy_demand_graetzls do |t|
      t.references :energy_demand, foreign_key: { on_delete: :cascade }, index: true
      t.references :graetzl, foreign_key: { on_delete: :cascade }, index: true
    end

    add_index :energy_offers, :region_id
    add_index :energy_demands, :region_id

  end
end
