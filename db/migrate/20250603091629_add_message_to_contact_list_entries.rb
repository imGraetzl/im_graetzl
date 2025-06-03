class AddMessageToContactListEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :contact_list_entries, :message, :text
    add_reference :contact_list_entries, :user, foreign_key: true
  end
end
