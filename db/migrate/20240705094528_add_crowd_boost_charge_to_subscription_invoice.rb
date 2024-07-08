class AddCrowdBoostChargeToSubscriptionInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :subscription_invoices, :crowd_boost_charge_amount, :decimal, precision: 10, scale: 2
    add_reference :subscription_invoices, :crowd_boost, index: true
  end
  change_table :crowd_boost_charges do |t|
    t.references :subscription_invoice, foreign_key: { on_delete: :nullify }, index: true
  end
end
