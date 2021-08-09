class CreateCoopDemand < ActiveRecord::Migration[6.1]
  def change

    create_table :coop_demand_categories do |t|
      t.string "name"
      t.string "icon"
      t.integer "position", default: 0
      t.jsonb "main_photo_data"
      t.string "slug"
      t.index ["slug"], name: "index_coop_demand_categories_on_slug", unique: true
    end

    create_table :coop_demands do |t|
      t.string "slogan"
      t.text "demand_description"
      t.text "personal_description"
      t.string "slug"
      t.string "first_name"
      t.string "last_name"
      t.string "website"
      t.string "email"
      t.string "phone"
      t.integer "status", default: 0
      t.jsonb "avatar_data"
      t.string "region_id"
      t.date "last_activated_at"
      t.timestamps

      t.index ["slug"], name: "index_coop_demands_on_slug"
      t.references :user, foreign_key: { on_delete: :cascade }, index: true
      t.references :location, foreign_key: { on_delete: :nullify }, index: true
      t.references :coop_demand_category, foreign_key: { on_delete: :nullify }, index: true
    end

    create_table :coop_demand_graetzls do |t|
      t.references :coop_demand, foreign_key: { on_delete: :cascade }, index: true
      t.references :graetzl, foreign_key: { on_delete: :cascade }, index: true
    end

    add_index :coop_demands, :region_id

  end
end
