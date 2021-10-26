class CreateToolDemand < ActiveRecord::Migration[6.1]
  def change
    create_table :tool_demands do |t|
      t.string "slogan"
      t.text "demand_description"
      t.text "usage_description"
      t.string "slug"
      t.string "first_name"
      t.string "last_name"
      t.string "website"
      t.string "email"
      t.string "phone"
      t.integer "status", default: 0
      t.string "region_id"
      t.date "last_activated_at"
      t.boolean "usage_period", default: false
      t.date "usage_period_from"
      t.date "usage_period_to"
      t.integer "usage_days"
      t.timestamps

      t.index ["slug"], name: "index_tool_demands_on_slug"
      t.references :user, foreign_key: { on_delete: :cascade }, index: true
      t.references :location, foreign_key: { on_delete: :nullify }, index: true
      t.references :tool_category, foreign_key: { on_delete: :nullify }, index: true
    end

    create_table :tool_demand_graetzls do |t|
      t.references :tool_demand, foreign_key: { on_delete: :cascade }, index: true
      t.references :graetzl, foreign_key: { on_delete: :cascade }, index: true
    end

    add_index :tool_demands, :region_id

  end
end
