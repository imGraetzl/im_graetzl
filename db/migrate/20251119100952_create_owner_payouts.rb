class CreateOwnerPayouts < ActiveRecord::Migration[7.2]
  def change
    create_table :owner_payouts, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.decimal :earnings_amount, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :refunds_amount, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :platform_fees_amount, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :transfer_amount, precision: 10, scale: 2, null: false, default: 0.0
      t.string :transfer_status, null: false, default: "payout_ready"
      t.string :region_id, null: false
      t.datetime :payout_attempted_at
      t.datetime :payout_completed_at
      t.datetime :payout_waived_at
      t.string :stripe_transfer_id

      t.timestamps
    end

    add_index :owner_payouts,
              %i[user_id period_start period_end],
              unique: true,
              name: "owner_payouts_on_user_period",
              if_not_exists: true

    create_table :owner_payout_items, if_not_exists: true do |t|
      t.references :owner_payout, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.decimal :booking_amount, precision: 10, scale: 2, null: false
      t.decimal :platform_fee_amount, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :refund_amount, precision: 10, scale: 2, null: false, default: 0.0
      t.string :region_id, null: false

      t.timestamps
    end

    add_index :owner_payout_items,
              %i[owner_payout_id booking_id],
              unique: true,
              name: "owner_payout_items_on_owner_payout_booking",
              if_not_exists: true
  end
end
