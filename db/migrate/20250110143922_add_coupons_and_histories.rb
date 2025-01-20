
class AddCouponsAndHistories < ActiveRecord::Migration[6.1]
  def change

    rename_column :subscriptions, :coupon, :coupon_code

    # Coupons Table
    create_table :coupons do |t|
      t.string :code, null: false, unique: true   # Benutzerdefinierter Code, eindeutig (z. B. TESTWEEK)
      t.string :stripe_id                         # Stripe-Coupon-ID (z. B. cpn_12345), optional
      t.decimal :amount_off, precision: 10, scale: 2 # Fixer Rabatt in EUR (z. B. 10 €)
      t.integer :percent_off                      # Prozentualer Rabatt (z. B. 10 für 10 %)
      t.string :duration, null: false             # Gültigkeitsdauer (once, forever)
      t.datetime :valid_from                      # Startzeitpunkt der Gültigkeit
      t.datetime :valid_until                     # Endzeitpunkt der Gültigkeit
      t.string :name                              # Name des Coupons (z. B. Neujahrsaktion)
      t.string :description                       # Beschreibung des Coupons
      t.boolean :enabled, default: true           # Gibt an, ob der Coupon aktiv ist
      t.string :region_id                         # Optionale region_id

      t.timestamps
    end

    # Sicherstellen, dass der Code eindeutig ist
    add_index :coupons, :code, unique: true

    # Erweiterung der subscription_plan Tabelle
    add_column :subscription_plans, :stripe_product_id, :string
    remove_column :subscription_plans, :coupon, :string

    # Hinzufügen der Referenz zu Subscription
    add_reference :subscriptions, :coupon, foreign_key: true

    # Hinzufügen der Referenz zu SubscriptionInvoice
    add_reference :subscription_invoices, :coupon, foreign_key: true

    # Coupon Histories Table
    create_table :coupon_histories do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade } # Wenn Nutzer gelöscht, dann Historie löschen
      t.references :coupon, foreign_key: true                              # Wenn Coupon gelöscht, dann Referenz leeren
      t.string :stripe_id                                                  # Stripe-Coupon-ID
      t.datetime :sent_at                                                  # Wann wurde der Coupon versendet
      t.datetime :redeemed_at                                              # Wann wurde der Coupon eingelöst
      t.timestamps
    end
  end
end
