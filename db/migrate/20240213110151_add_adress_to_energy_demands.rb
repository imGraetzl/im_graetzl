class AddAdressToEnergyDemands < ActiveRecord::Migration[6.1]
  def change
    add_column :energy_demands, :contact_name, :string
    add_column :energy_demands, :contact_website, :string
    add_column :energy_demands, :contact_email, :string
    add_column :energy_demands, :contact_phone, :string
    add_column :energy_demands, :contact_address, :string
    add_column :energy_demands, :contact_zip, :string
    add_column :energy_demands, :contact_city, :string
    add_column :energy_demands, :orientation_type, :string
  end
end
