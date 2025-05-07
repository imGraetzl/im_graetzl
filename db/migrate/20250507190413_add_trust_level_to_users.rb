class AddTrustLevelToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :trust_level, :integer, default: 0, null: false
  end
end