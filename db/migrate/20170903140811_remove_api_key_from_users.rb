class RemoveApiKeyFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :api_key, :string
  end
end
