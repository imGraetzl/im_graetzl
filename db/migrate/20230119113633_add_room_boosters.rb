class AddRoomBoosters < ActiveRecord::Migration[6.1]
  def change

    add_column :room_offers, :boosted, :boolean, default: false
    add_column :notifications, :sort_date, :date

    create_table :room_boosters do |t|

      t.decimal "amount", precision: 10, scale: 2
      t.string "status", default: "0"
      t.string "payment_status"
      t.string "invoice_number"
      t.string "payment_method"
      t.string "payment_card_last4"
      t.string "stripe_payment_method_id"
      t.string "stripe_payment_intent_id"
      t.string "company"
      t.string "name"
      t.string "address"
      t.string "zip"
      t.string "city"
      t.string "region_id"
      t.datetime "debited_at"
      t.date "send_at_date"
      t.timestamps

      t.references :user, foreign_key: { on_delete: :nullify }, index: true
      t.references :room_offer, foreign_key: { on_delete: :nullify }, index: true
    end

    add_index :room_boosters, :region_id

  end
end
