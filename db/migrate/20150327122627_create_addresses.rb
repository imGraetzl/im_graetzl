class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.belongs_to :user, index: true
      t.point :coordinates
      t.string :street_name
      t.string :street_number
      t.string :zip
      t.string :city

      t.timestamps
    end
  end
end
