class RemovePaidGoingTos < ActiveRecord::Migration[6.1]
  def change
    remove_column :going_tos, :amount
    remove_column :going_tos, :payment_status
    remove_column :going_tos, :payment_method
    remove_column :going_tos, :stripe_payment_intent_id
    remove_column :going_tos, :invoice_number
    remove_column :going_tos, :stripe_source_id
    remove_column :going_tos, :stripe_charge_id
  end
end
