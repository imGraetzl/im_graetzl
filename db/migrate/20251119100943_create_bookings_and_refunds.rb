class CreateBookingsAndRefunds < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings, if_not_exists: true do |t|
      t.references :bookable, polymorphic: true, null: false, index: false
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.string :payment_status, null: false, default: "incomplete"
      t.integer :source, null: false, default: 0
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: "eur"
      t.decimal :platform_fee_amount, precision: 10, scale: 2, null: false
      t.integer :platform_fee_collection_status, null: false, default: 0
      t.string :region_id, null: false
      t.string :stripe_payment_intent_id
      t.string :stripe_customer_id
      t.string :stripe_payment_method_id
      t.string :stripe_connect_account_id
      t.string :payment_method
      t.string :payment_wallet
      t.string :payment_card_last4
      t.string :application_fee_id
      t.string :invoice_number
      t.integer :payout_status
      t.datetime :debited_at
      t.datetime :failed_at
      t.datetime :disputed_at
      t.datetime :refunded_at
      t.datetime :canceled_at
      t.datetime :confirmed_at
      t.datetime :pending_expires_at
      t.string :dispute_status
      t.string :canceled_by

      t.timestamps
    end

    add_index :bookings,
              %i[bookable_type bookable_id starts_at],
              name: "index_bookings_on_bookable_type_id_starts_at",
              if_not_exists: true
    add_index :bookings,
              %i[status pending_expires_at],
              name: "index_bookings_on_status_and_pending_expires_at",
              if_not_exists: true
    add_index :bookings, :payment_status, if_not_exists: true
    add_index :bookings, :payout_status, if_not_exists: true
    add_index :bookings, :region_id, if_not_exists: true

    create_table :booking_slots, if_not_exists: true do |t|
      t.references :booking, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end
    add_index :booking_slots,
              %i[booking_id starts_at],
              unique: true,
              name: "index_booking_slots_on_booking_id_and_starts_at",
              if_not_exists: true

    create_table :refunds, if_not_exists: true do |t|
      t.references :booking, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :platform_fee_amount, precision: 10, scale: 2, null: false
      t.string :stripe_refund_id
      t.datetime :refunded_at, null: false
      t.string :canceled_by, null: false, default: "customer"
      t.integer :platform_fee_collection_status, null: false, default: 0
      t.string :region_id, null: false

      t.timestamps
    end
  end
end
