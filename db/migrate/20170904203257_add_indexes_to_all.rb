class AddIndexesToAll < ActiveRecord::Migration[5.0]
  def change
    add_index :locations, :created_at
    add_index :meetings, :created_at
    add_index :posts, :created_at
  end
end
