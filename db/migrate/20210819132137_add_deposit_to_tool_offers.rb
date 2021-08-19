class AddDepositToToolOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :tool_offers, :deposit, :decimal, precision: 10, scale: 2
  end
end
