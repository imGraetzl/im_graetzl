class AddUserAttributes < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :username, unique: true
      t.string :first_name
      t.string :last_name
      t.date :birthday
      t.string :gender
    end
  end
end