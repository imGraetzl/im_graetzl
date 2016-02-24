class AddDefaultCountryToBillingAddresses < ActiveRecord::Migration
  def up
    change_column :billing_addresses, :country, :string, default: 'Austria'
  end

  def down
    change_column_default :billing_addresses, :country, nil
  end
end
