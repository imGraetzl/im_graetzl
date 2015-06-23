class RenameAvatarField < ActiveRecord::Migration
  def change
    remove_column :users, :avatar, :string
    add_column :users, :avatar_id, :string
  end
end
