class AddSubscriptions < ActiveRecord::Migration[6.1]
  def change

    add_column :users, :payment_method, :string
    add_column :users, :payment_card_last4, :string

    create_table :subscription_plans do |t|
      t.string "name"
      t.text "description"
      t.decimal "amount", precision: 10, scale: 2
      t.string "interval"
      t.string "stripe_id"

      t.timestamps
    end

    create_table :subscriptions do |t|
      t.string "status", default: "0"
      t.string "stripe_id"
      t.string "stripe_plan"
      t.datetime "ends_at"
      t.string "region_id"

      t.references :user, foreign_key: { on_delete: :nullify }, index: true
      t.references :subscription_plan, foreign_key: { on_delete: :nullify }
      t.timestamps
    end

    create_table :subscription_invoices do |t|
      t.string "status", default: "0"
      t.string "stripe_id"
      t.string "stripe_payment_intent_id"
      t.string "invoice_number"
      t.string "invoice_pdf"

      t.references :user, foreign_key: { on_delete: :nullify }, index: true
      t.timestamps
    end

    add_index :subscriptions, :region_id

  end
end
