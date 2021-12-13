class AddLocationMenus < ActiveRecord::Migration[6.1]
  def change
    create_table :location_menus do |t|
      t.date "menu_from"
      t.date "menu_to"
      t.string "title"
      t.text "description"
      t.text "day_0_description"
      t.text "day_1_description"
      t.text "day_2_description"
      t.text "day_3_description"
      t.text "day_4_description"
      t.text "day_5_description"
      t.text "day_6_description"
      t.string "region_id"

      t.timestamps

      t.references :location, foreign_key: { on_delete: :cascade }, index: true
      t.references :graetzl, foreign_key: { on_delete: :nullify }, index: true

    end

    add_index :location_menus, :region_id

  end
end
