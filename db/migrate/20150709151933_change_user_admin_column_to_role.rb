class ChangeUserAdminColumnToRole < ActiveRecord::Migration
  def change
    remove_column :users, :admin, :boolean
    add_column :users, :role, :integer
  end
end
