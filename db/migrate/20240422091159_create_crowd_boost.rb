class CreateCrowdBoost < ActiveRecord::Migration[6.1]
  def change

    create_table :crowd_boosts do |t|
      t.integer "status", default: 0
      t.string "slug"
      t.string "title"
      t.string "slogan"
      t.text "description"
      t.jsonb "avatar_data"
      t.integer "threshold_pledge_count", default: 0
      t.decimal "threshold_funding_percentage", precision: 5, scale: 2
      t.decimal "boost_amount", precision: 10, scale: 2
      t.decimal "boost_precentage", precision: 5, scale: 2
      t.timestamps
    end

    create_table :crowd_boost_slots do |t|
      t.decimal "amount_limit", precision: 10, scale: 2
      t.integer "max_campaigns"
      t.date "starts_at"
      t.date "ends_at"
      t.timestamps
      t.references :crowd_boost, foreign_key: { on_delete: :cascade }, index: true
    end

    create_table :crowd_boost_slot_graetzls do |t|
      t.references :crowd_boost_slot, index: true, foreign_key: { on_delete: :cascade }
      t.references :graetzl, index: true, foreign_key: { on_delete: :cascade }
    end

    create_table :crowd_boost_pledges do |t|
      t.string "status"
      t.decimal "amount", precision: 10, scale: 2
      t.string "region_id"
      t.timestamps
      t.references :crowd_boost, foreign_key: { on_delete: :nullify }, index: true
      t.references :crowd_campaign, index: true, foreign_key: { on_delete: :nullify }
    end

    create_table :crowd_boost_charges, id: :uuid, default: "gen_random_uuid()", null: false do |t|
      t.string "payment_status"
      t.decimal "amount", precision: 10, scale: 2
      t.datetime "debited_at"
      t.string "contact_name"
      t.string "email"
      t.string "stripe_customer_id"
      t.string "stripe_payment_method_id"
      t.string "stripe_payment_intent_id"
      t.string "payment_method"
      t.string "payment_card_last4"
      t.string "payment_wallet"
      t.string "region_id"
      t.timestamps
      t.references :crowd_boost, foreign_key: { on_delete: :nullify }, index: true
      t.references :user, foreign_key: { on_delete: :nullify }, index: true
      t.references :crowd_pledge, foreign_key: { on_delete: :nullify }, index: true, type: :uuid
    end

    add_column :crowd_campaigns, :boost_status, :string
    add_column :crowd_pledges, :crowd_boost_charge_amount, :decimal, precision: 10, scale: 2

    add_reference :crowd_pledges, :crowd_boost, index: true
    add_reference :crowd_campaigns, :crowd_boost_slot, index: true

    add_index :crowd_boost_pledges, :region_id
    add_index :crowd_boost_charges, :region_id

  end
end
