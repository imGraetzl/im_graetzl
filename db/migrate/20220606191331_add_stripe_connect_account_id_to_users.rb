class AddStripeConnectAccountIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :stripe_connect_account_id, :string
    add_column :users, :stripe_connect_ready, :boolean, default: false
  end
end
