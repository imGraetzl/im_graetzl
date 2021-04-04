class AddGroupUsersCountToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :group_users_count, :integer
  end
end
