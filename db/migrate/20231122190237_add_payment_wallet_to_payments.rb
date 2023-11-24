class AddPaymentWalletToPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :payment_wallet, :string
    add_column :room_boosters, :payment_wallet, :string
    add_column :room_rentals, :payment_wallet, :string
    add_column :tool_rentals, :payment_wallet, :string
    add_column :users, :payment_wallet, :string
    add_column :zuckerls, :payment_wallet, :string
  end
end
