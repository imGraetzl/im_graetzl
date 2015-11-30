class AddHoursToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :hours, :text
  end
end
