class AddAmountToSubscriptionInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :subscription_invoices, :amount, :decimal, precision: 10, scale: 2
  end
end
