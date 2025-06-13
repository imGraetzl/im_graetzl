class AddPaymentFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :payment_method_stripe_id, :string
    add_column :users, :payment_exp_month, :string
    add_column :users, :payment_exp_year, :string
  end
end
