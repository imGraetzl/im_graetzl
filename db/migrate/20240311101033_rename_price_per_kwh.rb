class RenamePricePerKwh < ActiveRecord::Migration[6.1]
  def change
    rename_column :energy_offers, :price_per_kwh, :producer_price_per_kwh
    add_column :energy_offers, :consumer_price_per_kwh, :decimal, precision: 10, scale: 2
  end
end
