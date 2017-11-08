class AddContactDetailsToRooms < ActiveRecord::Migration[5.0]
  def change
    change_table :room_offers do |t|
      t.string :first_name
      t.string :last_name
      t.string :website
      t.string :email
      t.string :phone
    end

    change_table :room_demands do |t|
      t.string :first_name
      t.string :last_name
      t.string :website
      t.string :email
      t.string :phone
      t.belongs_to :location, foreign_key: true, index: true
    end
  end
end
