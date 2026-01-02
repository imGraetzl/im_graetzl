class AddStatusToContactListEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :contact_list_entries, :status, :integer, default: 0, null: false
  end
end
