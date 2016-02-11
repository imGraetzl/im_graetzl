class CreateBillingAddresses < ActiveRecord::Migration
  def change
    create_table :billing_addresses do |t|
      t.belongs_to :location, index: true
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :street
      t.string :zip
      t.string :city
      t.string :country

      t.timestamps null: false
    end
  end
end
