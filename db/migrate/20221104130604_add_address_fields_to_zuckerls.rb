class AddAddressFieldsToZuckerls < ActiveRecord::Migration[6.1]
  def change

    add_column :zuckerls, :amount, :decimal, precision: 10, scale: 2
    add_column :zuckerls, :company, :string
    add_column :zuckerls, :name, :string
    add_column :zuckerls, :address, :string
    add_column :zuckerls, :zip, :string
    add_column :zuckerls, :city, :string
    
  end
end
