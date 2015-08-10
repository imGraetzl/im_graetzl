class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :website
      t.string :email
      t.string :phone
      t.belongs_to :location, index: true

      t.timestamps null: false
    end
  end
end
