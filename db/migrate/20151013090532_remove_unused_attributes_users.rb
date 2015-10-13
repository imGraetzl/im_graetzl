class RemoveUnusedAttributesUsers < ActiveRecord::Migration
  def up
    remove_column :users, :birthday
    remove_column :users, :gender
  end

  def down
    add_column :users, :birthday, :date
    add_column :users, :gender, :integer
  end
end
