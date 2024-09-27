class AddContactList < ActiveRecord::Migration[6.1]
  def change
    create_table :contact_list_entries do |t|
      t.string :name
      t.string :email, default: "", null: false
      t.string :phone
      t.string :region_id
      t.string :via_path
      t.timestamps
    end
  end
end