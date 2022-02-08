class CreateCrowdfunding < ActiveRecord::Migration[6.1]
  def change
    create_table :crowdfundings do |t|
      t.integer "status", default: 0
      t.string "slug"
      t.string "title"
      t.string "slogan"
      t.string "address_street"
      t.string "address_zip"
      t.string "address_city"
      t.string "address_description"
      t.geometry "address_coordinates"
      t.text "description"
      t.text "support_description"
      t.text "about_description"
      t.text "benefit_description"
      t.decimal "funding_1_amount", precision: 10, scale: 2
      t.decimal "funding_2_amount", precision: 10, scale: 2
      t.text "funding_1_description"
      t.text "funding_2_description"
      t.date "startdate"
      t.date "enddate"
      t.boolean "benefit"
      t.integer "runtime", default: 30
      t.integer "billable"
      t.string "video"

      t.string "cover_photo_id"
      t.string "cover_photo_content_type"
      t.jsonb "cover_photo_data"

      t.string "contact_company"
      t.string "contact_name"
      t.string "contact_address"
      t.string "contact_zip"
      t.string "contact_city"
      t.string "contact_website"
      t.string "contact_email"
      t.string "contact_phone"

      t.string "region_id"

      t.timestamps

      t.index ["slug"], name: "index_crowdfundings_on_slug"
      t.references :user, foreign_key: { on_delete: :cascade }, index: true
      t.references :graetzl, foreign_key: { on_delete: :nullify }, index: true
      t.references :location, foreign_key: { on_delete: :nullify }, index: true
      t.references :room_offer, foreign_key: { on_delete: :nullify }, index: true
    end

    create_table :crowd_categories do |t|
      t.string :title
      t.string :css_ico_class
      t.string :main_photo_id
      t.string :main_photo_content_type
      t.jsonb :main_photo_data
      t.string :slug
      t.integer :position, default: 0
      t.timestamps

      t.index ["slug"], name: "index_crowd_categories_on_slug"
    end

    create_table :crowd_rewards do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.integer :limit
      t.string :title
      t.text :description
      t.integer :delivery_weeks
      t.boolean :delivery_address_required
      t.string :question
      t.jsonb :avatar_data
      t.references :crowdfunding, index: true, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    create_table :crowd_donations do |t|
      t.integer :donation_type, default: 0
      t.integer :limit
      t.string :title
      t.text :description
      t.date :startdate
      t.date :enddate
      t.string :question
      t.references :crowdfunding, index: true, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    create_join_table :crowd_categories, :crowdfundings do |t|
      t.index :crowdfunding_id
      t.index :crowd_category_id
    end

    add_index :crowdfundings, :region_id

  end
end
