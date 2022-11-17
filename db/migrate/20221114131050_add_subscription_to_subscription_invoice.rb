class AddSubscriptionToSubscriptionInvoice < ActiveRecord::Migration[6.1]
  def change
    add_reference :subscription_invoices, :subscription, index: true
  end
end
