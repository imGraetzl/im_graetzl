class DropContactsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :contacts
  end
end
