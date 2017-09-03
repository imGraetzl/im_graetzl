class CreateApiAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :api_accounts do |t|
      t.string :name
      t.string :api_key, unique: true
      t.boolean :enabled, default: true
      t.timestamps
    end
  end
end
