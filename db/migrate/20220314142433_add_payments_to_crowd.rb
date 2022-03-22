class AddPaymentsToCrowd < ActiveRecord::Migration[6.1]
  def change
    rename_column :crowd_pledges, :anwser, :answer
    rename_column :crowd_donation_pledges, :anwser, :answer
    rename_column :crowd_pledges, :amount, :donation_amount
    add_column :crowd_pledges, :total_price, :decimal, precision: 10, scale: 2

    add_column :crowd_pledges, :stripe_customer_id, :string
    add_column :crowd_pledges, :stripe_payment_method_id, :string
    add_column :crowd_pledges, :stripe_payment_intent_id, :string
    add_column :crowd_pledges, :payment_method, :string
    add_column :crowd_pledges, :payment_card_last4, :string
  end
end
